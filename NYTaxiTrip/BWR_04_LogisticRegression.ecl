IMPORT STD;
IMPORT ML_Core;
IMPORT ML_Core.Types;
IMPORT LogisticRegression AS LR;

#WORKUNIT('NAME', '4_LogisticRegression');

//Reading Taxi_Weather Data
Layout := RECORD
  STD.Date.Date_t date;
  REAL8 precipintensity;
  INTEGER trip_counts;
END;
raw := DATASET('~thor::taxi::traindata', Layout, THOR);

//Enhance raw data
enhancedLayout := RECORD
  INTEGER id;
  INTEGER month_of_year;
  INTEGER day_of_week;
  REAL8   precipintensity;
  INTEGER trip_counts;
END;

enhancedData := PROJECT(raw, TRANSFORM(enhancedLayout,
                                        SELF.id := COUNTER,
                                        SELF.day_of_week := (INTEGER) Std.Date.DayOfWeek(LEFT.date),
                                        SELF.month_of_year := (INTEGER) LEFT.date[5..6],
                                        SELF.precipintensity := LEFT.precipintensity,
                                        SELF.trip_counts := LEFT.trip_counts));

avgTrip := AVE(enhancedData, trip_counts);
//Add trend layout
trainLayout := RECORD
  INTEGER id;
  INTEGER month_of_year;
  INTEGER day_of_week;
  REAL8   precipintensity;
  INTEGER trend;
END;

trainData := PROJECT(enhancedData, TRANSFORM(trainLayout,
                                            SELF.trend := IF(LEFT.trip_counts < avgTrip, 0, 1),
                                            SELF := LEFT));

//Transform to Machine Learning Dataframe, such as NumericField
ML_Core.ToField(trainData, NFtrain);

//Independent and Dependent data
DStrainInd := NFtrain(number < 4);
DStrainDpt := PROJECT(NFtrain(number = 4), TRANSFORM(Types.DiscreteField, SELF.number := 1, SELF := LEFT));

//Training LogisticRegression Model
mod_bi := LR.BinomialLogisticRegression(100,0.00001).getModel(DStrainInd, DStrainDpt);

//Prediction
predict_bi := LR.BinomialLogisticRegression().Classify(mod_bi, DStrainInd);
OUTPUT(predict_bi);