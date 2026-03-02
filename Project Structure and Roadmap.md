# Mental Health Dashboard

## Project structure


mental-health-dashboard/
│
├── data/                # raw CSV files (OWID, SAMHSA, CDC)
├── sql/                 # SQL scripts for creating tables + queries
├── notebooks/           # Jupyter notebooks for exploration
├── dashboard/           # Streamlit or Dash app files
├── README.md            # project overview
└── requirements.txt     # Python dependencies

## Roadmap to Analyzing Data

### Phase 1: Define the purpose of each dataset

    1. OWID (Global Mental Illness Prevalence)
        How does it compare to other countries?
        What are the global trends in depression, anxiety, suicide rates?
    2. CDC (Mental Health Care in Last 4 Weeks)
        Who is receiving mental health services?
        What demographic groups are over- or under- represented?
    3. CDC (U.S. Mental Health Indicators)
        How do mental health symptoms trend over time?
        What are the behavioral or social determinants?
        How does mental health vary by state?

### Phase 2: Build the SQL Database Structure
     * Three separate tables, not one merged structure

### Phase 3: Load Data in SQL
### Phase 4: Write SQL Queries for Each Dataset
    * OWID: Compare U.S. vs Global
    * CDC: Mental Health Care in Last 4 Weeks
    * CDC: State-level Indicators 
### Phase 5: Analyze in Python 
    *Use:
        *Pandas for data manipulations
        *Plotly for charts
        *Streamlit or Dash for the dashboard 
### Phase 6: Build the Dashboard Structure
    * Three tabs:
        * Tab 1: Global Mental Health
            *U.S. vs. gloabl line chart
            *Choropleth map
            *Top 10 countries with the highest prevalence
        * Tab 2: U.S. Treatment Patterns (CDC)
            *Demographics of clients
            *Diagnoses distribution
            *Services used
        * Tab 3: U.S. Mental Health Indicators (CDC)
            *State-level heatmap
            *Trends over time
            *Social determinants
### Phase 7: Add Interpretation Panels
    * For each tab, include:
        *Key findings
        *Public health implications
        *Limitations (e.g., different years, different methodologies)
### Phase 8: Package for Your Portfolio
    *Include:
        *A GitHub Repo
        *A README explaining your methods
        *A deployed dashboard
        *A resume bullet
        


