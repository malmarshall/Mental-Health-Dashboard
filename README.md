# Overview

When gaining my MPH, there was a lot of focus on data analytics and epidemiological trends. One topic that comes up a lot is mental health and social determinants of health. This project was creted out of a curiosity about mental health care and access in the rest of the world. Additionally, I wanted to take a deeper dive into the skills that I've learned and apply them to something personally relevant to me. 

# The Questions

Below are the questions I hoped to answer in this project:

1. Where is mental illness most prevalent across the globe?
2. How does mental illness in the U.S. compare to global trends?
3. Who is receiving mental health services?
4. What demographic groups are over- or under- represented?
5. How do mental health symptoms trend over time?
6. How does mental health vary by state?
  
# Tools I used

In order to perform a thorough analysis of the data, I utilized several tools:

- **Python:**
      - **Pandas Library:**
      - **Matplotlib Library:**
      - **Seaborn Library:**
- **Jupyter Notebooks:**
- **Visual Studio Code:**
- **Git & GitHub:**
- **Database & Analysis Tools:** PostgreSQL 

# Data Preparation and Cleanup

This section outlines the steps that I took to clean each dataset for later analysis and visualization, ensuring accuracy and standardization of variables. 

## SQL

### Import and Clean Up Data

I start by importing my dataset and doing some initial data cleaning to ensure integrity and quality of the data.

```SQL
CREATE TABLE mh_care_cdc
(
    indicator VARCHAR(255),
    "group" VARCHAR(255),
    state VARCHAR(255),
    subgroup VARCHAR(255),
    phase VARCHAR(255),
    time_period VARCHAR(255),
    time_period_label VARCHAR(255),
    time_start DATE,
    time_end DATE,
    value VARCHAR(255),
    low_ci VARCHAR(255),
    high_ci VARCHAR(255),
    con_int VARCHAR(255),
    quart_range VARCHAR(255),
    supp_flag VARCHAR(255)
);

-- Insert data into mh_care_cdc table from the CDC dataset
COPY mh_care_cdc
FROM '/workspaces/Mental-Health-Dashboard/data/mh_care_cdc.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8', NULL '');


-- Checks for duplicates in the mh_care_cdc to ensure data integrity and to identify any potential issues with duplicate records that may affect analysis and visualization in the Mental Health Dashboard.

SELECT indicator, demo_group, subgroup, time_period_label, COUNT(*)
FROM mh_care_cdc
GROUP BY indicator, demo_group, subgroup, time_period_label
HAVING COUNT(*) > 1;

-- Run query to check the first 10 rows of the cdc mental health care table 
SELECT *
FROM mh_care_cdc
ORDER BY year DESC, value DESC;
```

To focus my analysis on the variables of interest, I dropped any unnecessary columns and standardized variable names that I would like to compare with other datasets in the future.

```SQL
-- Final check of the mh_care_cdc after all transformations and cleaning steps to ensure that the data is ready for analysis and visualization in the Mental Health Dashboard.

SELECT *
FROM mh_care_cdc
ORDER BY year DESC, value DESC;
```
These steps were then repeated for the Depression Indicators dataset and the Global Anxiety/Depression Prevalence dataset. Once I felt comfortable that all necessary cleaning/transformation steps were taken, I then uploaded the datasets to python for visualization. 

View my notebook with detailed steps here:
  - [mh_care_cdc](mhcare_cdc_table.sql)
  - [indicators_cdc](indicators_cdc_table.sql)
  - [global_owid](global_owid_table.sql)

## Python

### Import libraries and set up database connection

```python
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import nbformat
from sqlalchemy import create_engine
engine = create_engine('postgresql+psycopg2://postgres:****@localhost:5432/postgres')

# Imports mh_care_cdc dataset from PostgreSQL and prints first 5 rows to ensure proper transfer

mh_care_df = pd.read_sql('mh_care_cdc', con=engine)
mh_care_df.head()
```

### Grouping Data for Visualization

I grouped each variable based on their demographics and further refined each subgroup into a pivot table. This helped allow for stratification based on age, state, gender, etc. that I could then use later in my visualization steps. 

```python
mhcare_age_pivot = mh_care_df[mh_care_df['demo_group']=='By Age'].pivot_table(
    values=['value', 'low_ci', 'high_ci'],
    index=['year','subgroup', 'indicator'],
    aggfunc='median',
    margins=False
)

mhcare_age_pivot 
```
These steps were repeated using each demographic group. The same steps were repeated for the Mental Health Indicators table and the Global Anxiety/Depression Prevalence table. 

Notebook with detailed steps:
- [mh_care_cdc](mh_care.ipynb)
- [indicators_cdc](indicators_cdc.ipynb)
- [global_owid](global_owid.ipynb)

# The Analysis 

Here's how I approached each question:

## 1. Where is mental illness most prevalent across the globe?

To determine the highest prevalence of mental illness globally, I filtered the global_owid data for the largest 10 values and included a column to round to the nearest hundreth for percentage estimation. 

### Visualize Data

```python
top = (sns.catplot(
    top_10,
    x='per_round',
    y='entity',
    hue='entity',
    kind='bar',
    palette='pastel',
    legend=False)
    .set_axis_labels(
        'Percent Reported',
        'Country')
    .figure.suptitle(
        'Top 10 Countries with Anxiety/Depression',
        y=1.05)
    )
```

### Results

![Top 10 Countries with Anxiety/Depression](images/Top_10_Countries.png)

### Interpretation

- Peru saw the highest prevalence of anxiety/depression at 49.35%
- Countries with the highest prevalence of Anxiety/Depression fall under the 'upper-middle-income' and 'lower-middle-income' country classification. This is surprising to me, because it does not trend in a way that I would have expected (where lower-income countries would have the highest rates of Anxiety/Depression). 
- This data reflects reportings from 2020, when the COVID-19 pandemic was at its peak. The authors were unable to comment how much this may have affected the results or in what ways, but it's important to note since lockdown restrictions may have caused increased feelings of isolation and anxiety.

## 2. How does mental illness in the U.S. compare?

### Visualize Data

 ```Python
fig = px.choropleth(
    global_owid_df,
    locations=global_owid_df['code'],
    locationmode='ISO-3',
    color='per_round',
    hover_name='entity',
    color_continuous_scale='orrd',
    title='Percent Reporting Anxiety/Depression by Country (2020)'
)
fig.show()
```

### Results
### Interpretation

- U.S. prevalence of anxiety/depression in 2020 was at 21.27% (or nearly one in five people). In Peru, where prevalence is highest globally, nearly half of all people experienced anxiety/depression.
- The U.S. prevalence matches closely with the worldwide prevalence of 19%
- This trend is similar to those seen in other high-income countries, though some report closer to one in three people experiencing anxiety/depression.

## 3. Who is receiving mental health care services?

To answer this question, I utilized the mental health care in the last 4 weeks dataset from the CDC. Upon intial query, I identified a critical mistake in my SQL cleanup. Identifying the top scorers based on value showed that there were multiple responses for similar demographic groups in the same year. Looking at the original dataset, I noted that there was an additional column that further identified these responses by date range (4 week time span across each year). I should have either averaged values within the same date range or left the column untouched and added the column as a groupby variable in my python analysis. I chose the later approach for ease and potential use later on in question 5. 


### Visualize Data
### Results
### Interpretation

- 62.9% of 

## 4. What demographic groups are over- or under-represented?

### Visualize Data
### Results
### Interpretation

## 5. How do mental health symptoms trend over time?

### Visualize Data
### Results

![Indicators Over Time](images/Line_Indicators_by_Year_and_Demo_Group.png)

### Interpretation

- Indicators were markedly higher based on income level than for any other demographic group. Race/Hispanic ethnicity followed behind in second place. 
- Across the board, reportings of depression drop around 2016 but then shoot back up in 2018. The steepest trend is observed in the sex stratification, though this line matches almost exactly to the national estimate.
- Though there are fluctuations in yearly reportings, the line graph shows that depression prevalence is generally on the rise across the 12-year span. 

## 6. How does mental health vary by state?

### Visualize Data
### Results

![Chloropleth Map](images/mh_care_chloropleth.html)

### Interpretation

# What I Learned
# Insights


# Challenges I Faced

For my first coding project, I faced a number of different obstacles:

- **Finding Datasets**: Despite the topic's popularity, finding easily accesible datasets that provided the information I was looking for proved to be quite a challenge.
- **Unfamiliar Data Visualization Tools**: While I understood the basics of python programming, my knowledge of libraries available was mostly limited to pandas and matplotlib. This project also integrated seaborn, numpy, and a few other libraries that I wasn't as familiar with
- **Prioritizing Insights**: Once I was able to find appropriate datasets, there was a large wealth of information available for me to extract and use for this project. Rather than include it all, I had to really step back and determine what information would provide the most 'bang for buck'. 

# Conclusion
