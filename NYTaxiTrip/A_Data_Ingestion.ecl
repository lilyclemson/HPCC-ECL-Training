IMPORT STD;

//Reading Taxi_Weather Data
EXPORT A_Data_Ingestion := MODULE

EXPORT Layout := RECORD
  STRING date;
  STRING precipintensity;
  STRING trip_counts;
END;

EXPORT raw := DATASET('~NY_SampleInput.csv', Layout, CSV(HEADING(1)));

END;
