
from dotenv import load_dotenv
import os
from langchain_core.tools import tool

from azure.core.credentials import AzureKeyCredential
from azure.search.documents import SearchClient

load_dotenv()
ai_search_url = os.getenv("ai_search_url")
ai_search_key = os.getenv("ai_search_key")
ai_index_name = os.getenv("ai_index_name")
ai_semantic_config = os.getenv("ai_semantic_config")


@tool
def perform_search_based_qna(query):
    """
    call this function to look up documentation and manuals to look for answers to the query posed by the Customer.

    """
    print("performing search based QnA")
    
    credential = AzureKeyCredential(ai_search_key)
    client = SearchClient(
        endpoint=ai_search_url,
        index_name=ai_index_name,
        credential=credential,
    )
    results = list(
        client.search(
            search_text=query,
            query_type="semantic",
            semantic_configuration_name=ai_semantic_config,
            top=5,
        )
    )
    return results
