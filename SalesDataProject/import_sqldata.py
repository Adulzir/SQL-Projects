# Method modified from https://pythontic.com/pandas/serialization/mysql
# Script written by Erika Altamirano 

# Import required libraries
import pandas as pd
from sqlalchemy import create_engine
import pymysql

# Create table name(s) for schema/database on MySql
tablename1 = 'SalesData'

# Use Pandas to read csv file(s) into a dataframe
df1 = pd.read_excel('/enter/path/name/to/sales_data_sample.xls') #, encoding = "ISO-8859-1"

# Obtain a SQLAlchemy engine object to connect to the MySQL database server by providing required credentials
engine = create_engine('mysql+pymysql://root:password@localhost/Sales')

# Using the engine object, connect to the MySQL server by calling the connect() method
dbconnection = engine.connect()

#Invoke to_sql() method on the pandas dataframe instance and specify the table name and database connection. 
# This creates a table in MySQL database server and populates it with the data from the pandas dataframe
frame1 = df1.to_sql(tablename1, dbconnection)

# Close connection to MySQL server
dbconnection.close()