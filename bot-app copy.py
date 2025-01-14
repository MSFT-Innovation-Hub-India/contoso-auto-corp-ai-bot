from dotenv import load_dotenv
import os
from langchain_openai import AzureChatOpenAI
from typing import Annotated
from typing_extensions import TypedDict
from langgraph.graph import StateGraph, START, END
from langgraph.checkpoint.memory import MemorySaver
from typing_extensions import TypedDict
import traceback
import uuid
from langgraph.graph.message import AnyMessage, add_messages
from IPython.display import display, Image
from service_requests.db_tools import (
    store_service_feedback,
    fetch_customer_information,
    get_available_service_slots,
    create_service_appointment_slot,
)
from service_requests.search_tools import perform_search_based_qna
from langgraph.prebuilt import ToolNode, tools_condition
import datetime

from langchain_core.runnables import Runnable, RunnableConfig
from langchain_core.prompts import ChatPromptTemplate

load_dotenv()
az_openai_endpoint = os.getenv("AZURE_OPENAI_ENDPOINT")
az_openai_key = os.getenv("AZURE_OPENAI_KEY")
az_openai_deployment_name = os.getenv("AZURE_OPENAI_DEPLOYMENT_NAME")
az_openai_embedding_deployment_name = os.getenv(
    "AZURE_OPENAI_EMBEDDINGS_DEPLOYMENT_NAME"
)
az_api_type = os.getenv("API_TYPE")
az_openai_version = os.getenv("API_VERSION")

llm = AzureChatOpenAI(
    azure_endpoint=az_openai_endpoint,
    azure_deployment=az_openai_deployment_name,
    api_key=az_openai_key,
    openai_api_type=az_api_type,
    api_version=az_openai_version,
)

thread_id = str(uuid.uuid4())
config = {
    "configurable": {
        "customer_name": "Srikantan",
        "thread_id": thread_id,
    }
}

tools = [
    store_service_feedback,
    fetch_customer_information,
    get_available_service_slots,
    create_service_appointment_slot,
    perform_search_based_qna,
]
tool_node = ToolNode(tools=tools)




class State(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]
    customer_info: str
    current_datetime: str


class Assistant:
    def __init__(self, runnable: Runnable):
        self.runnable = runnable

    def __call__(self, state: State, config: RunnableConfig):
        while True:
            result = self.runnable.invoke(state)

            if not result.tool_calls and (
                not result.content
                or isinstance(result.content, list)
                and not result.content[0].get("text")
            ):
                messages = state["messages"] + [("user", "Respond with a real output.")]
                state = {**state, "messages": messages}
            else:
                break
        return {"messages": result}

def customer_info(state: State):
    if state.get("customer_info"):
        return {"customer_info": state.get("customer_info")}
    else:
        state["customer_info"] = fetch_customer_information.invoke({})
        return {"customer_info": state.get("customer_info")}


service_scheduling_prompt = ChatPromptTemplate(
    [
        (
            "system",
            
                "You are a Assistant tasked with helping Customers with Service appointment bookings and taking rating feedback."
                "when getting appointment slots, the datetime must be the same or later than the system datetime"
                "when customer wants to provide service feedback, prompt asking for all the information, and have a confirmation message before inserting into the database"
                " \n\nCurrent customer service history is as follows:\n<Customer_service_records>\n{customer_info}\n</Customer_service_records>"
            "\nCurrent time: {time}."
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

service_scheduling_runnable = service_scheduling_prompt | llm.bind_tools(
    tools
)

builder = StateGraph(State)
builder.add_node("chatbot", Assistant(service_scheduling_runnable))
builder.add_node("fetch_customer_info", customer_info)
builder.add_edge("fetch_customer_info", "chatbot")
builder.add_node("tools", tool_node)
builder.add_conditional_edges(
    "chatbot",
    tools_condition,
)
builder.add_edge(START, "fetch_customer_info")
builder.add_edge("tools", "chatbot")

memory = MemorySaver()
graph = builder.compile(checkpointer=memory)


## graph_image = graph.get_graph().draw_mermaid_png()
# with open("graph_bot_app.png", "wb") as f:
#     f.write(graph_image)
# display(Image("graph_bot_app.png"))


def stream_graph_updates(user_input: str):
    events = graph.stream(
        {"messages": [("user", user_input)]},
        config,
        subgraphs=True,
        stream_mode="values",
    )
    l_events = list(events)
    msg = list(l_events[-1])
    r1 = msg[-1]["messages"]
    # response_to_user = msg[-1].messages[-1].content

    print(r1[-1].content)


while True:
    try:
        user_input = input("User: ")
        if user_input.lower() in ["quit", "exit", "q"]:
            print("Goodbye!")
            break

        stream_graph_updates(user_input)
    except Exception as e:
        print("An error occurred:", e)
        traceback.print_exc()
        # stream_graph_updates(user_input)
        break
