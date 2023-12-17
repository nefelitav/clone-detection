import json
import pandas as pd

with open('//Users//anand//clone-detection//results//VisualLocation.json', 'r') as file:
    clonesLocations = json.load(file)

with open('//Users//anand//clone-detection//results//VisualLines.json', 'r') as file:
    clonesLines = json.load(file)

# Prepare data for DataFrame
data = []
for key, values in clonesLocations.items():
    row = [key] + [clonesLines[key]] + [len(values) + 1] + values  # Create a row with the key and its list elements
    data.append(row)

# Create DataFrame
df = pd.DataFrame(data)

# Column names
column_names = ["Clone Class"] + ["No. of lines"] + ["No. of clones"] + [f"Clone {i+1}" for i in range(df.shape[1]-3)]
df.columns = column_names

# Writing DataFrame to Output Excel
output = '//Users//anand//clone-detection//results//output.xlsx'
df.to_excel(output, index=False)

print(f"Data written to {output}")
