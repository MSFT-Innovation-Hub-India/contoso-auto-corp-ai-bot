/****** Object:  Table [dbo].[Customers]    Script Date: 1/14/2025 8:57:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Customers](
	[customer_id] [int] NOT NULL,
	[name] [varchar](100) NULL,
	[contact_number] [varchar](15) NULL,
	[email] [varchar](100) NULL,
	[address] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[customer_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


/****** Object:  Table [dbo].[Vehicles]    Script Date: 1/14/2025 8:58:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Vehicles](
	[vehicle_id] [int] NOT NULL,
	[customer_id] [int] NULL,
	[model] [varchar](50) NULL,
	[year] [int] NULL,
	[registration_number] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[vehicle_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Vehicles]  WITH CHECK ADD FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO


/****** Object:  Table [dbo].[Service_Centers]    Script Date: 1/14/2025 8:59:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Service_Centers](
	[center_id] [int] NOT NULL,
	[name] [varchar](100) NULL,
	[location] [varchar](100) NULL,
	[contact_number] [varchar](15) NULL,
PRIMARY KEY CLUSTERED 
(
	[center_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


/****** Object:  Table [dbo].[Service_Types]    Script Date: 1/14/2025 9:00:46 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Service_Types](
	[service_type_id] [int] NOT NULL,
	[service_name] [varchar](50) NULL,
	[duration_minutes] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[service_type_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


/****** Object:  Table [dbo].[Service_Schedules]    Script Date: 1/14/2025 9:01:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Service_Schedules](
	[schedule_id] [int] NOT NULL,
	[vehicle_id] [int] NULL,
	[service_type_id] [int] NULL,
	[service_date] [date] NULL,
	[start_time] [time](7) NULL,
	[end_time] [time](7) NULL,
	[status] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[schedule_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Service_Schedules]  WITH CHECK ADD FOREIGN KEY([service_type_id])
REFERENCES [dbo].[Service_Types] ([service_type_id])
GO

ALTER TABLE [dbo].[Service_Schedules]  WITH CHECK ADD FOREIGN KEY([vehicle_id])
REFERENCES [dbo].[Vehicles] ([vehicle_id])
GO

/****** Object:  Table [dbo].[Technicians]    Script Date: 1/14/2025 9:02:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Technicians](
	[technician_id] [int] NOT NULL,
	[name] [varchar](100) NULL,
	[center_id] [int] NULL,
	[specialization] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[technician_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Technicians]  WITH CHECK ADD FOREIGN KEY([center_id])
REFERENCES [dbo].[Service_Centers] ([center_id])
GO


/****** Object:  Table [dbo].[Appointments]    Script Date: 1/14/2025 8:56:30 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Appointments](
	[appointment_id] [int] NOT NULL,
	[schedule_id] [int] NULL,
	[technician_id] [int] NULL,
	[appointment_status] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[appointment_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO



ALTER TABLE [dbo].[Appointments]  WITH CHECK ADD FOREIGN KEY([schedule_id])
REFERENCES [dbo].[Service_Schedules] ([schedule_id])
GO

ALTER TABLE [dbo].[Appointments]  WITH CHECK ADD FOREIGN KEY([technician_id])
REFERENCES [dbo].[Technicians] ([technician_id])
GO


CREATE TABLE Service_Feedback (
    feedback_id INT PRIMARY KEY IDENTITY(1,1),
    schedule_id INT,
    customer_id INT,
    feedback_text NVARCHAR(MAX),
    feedback_vector VECTOR(1536), -- Using a 1536-dimensional vector for overall feedback embeddings
    rating_quality_of_work INT CHECK (rating_quality_of_work BETWEEN 1 AND 5),
    rating_timeliness INT CHECK (rating_timeliness BETWEEN 1 AND 5),
    rating_politeness INT CHECK (rating_politeness BETWEEN 1 AND 5),
    rating_cleanliness INT CHECK (rating_cleanliness BETWEEN 1 AND 5),
    rating_overall_experience INT CHECK (rating_overall_experience BETWEEN 1 AND 5),
    feedback_date DATE,
    FOREIGN KEY (schedule_id) REFERENCES Service_Schedules(schedule_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);



-- Insert into Customers
INSERT INTO Customers (customer_id, name, contact_number, email, address) VALUES
(1, 'Ravi Kumar', '9876543210', 'ravi.kumar@example.com', '123 MG Road, Bengaluru'),
(2, 'Anita Sharma', '9123456780', 'anita.sharma@example.com', '456 Brigade Road, Bengaluru');

-- Insert into Vehicles
INSERT INTO Vehicles (vehicle_id, customer_id, model, year, registration_number) VALUES
(1, 1, 'Splendor Plus', 2018, 'KA01AB1234'),
(2, 2, 'HF Deluxe', 2020, 'KA02CD5678');

-- Insert into Service_Types
INSERT INTO Service_Types (service_type_id, service_name, duration_minutes) VALUES
(1, 'General Service', 60),
(2, 'Oil Change', 30),
(3, 'Brake Inspection', 45);

-- Insert into Service_Schedules
INSERT INTO Service_Schedules (schedule_id, vehicle_id, service_type_id, service_date, start_time, end_time, status) VALUES
(1, 1, 1, '2024-12-02', '10:00', '11:00', 'Scheduled'),
(2, 2, 2, '2024-12-02', '11:30', '12:00', 'Scheduled'),
(3, 1, 3, '2024-12-02', '14:00', '14:45', 'Scheduled');

-- Insert into Service_Centers
INSERT INTO Service_Centers (center_id, name, location, contact_number) VALUES
(1, 'Main Service Center', 'MG Road, Bengaluru', '0801234567');

-- Insert into Technicians
INSERT INTO Technicians (technician_id, name, center_id, specialization) VALUES
(1, 'Suresh Babu', 1, 'General Service'),
(2, 'Meena Rao', 1, 'Oil Change');

-- Insert into Appointments
INSERT INTO Appointments (appointment_id, schedule_id, technician_id, appointment_status) VALUES
(1, 1, 1, 'Assigned'),
(2, 2, 2, 'Assigned'),
(3, 3, 1, 'Assigned');
