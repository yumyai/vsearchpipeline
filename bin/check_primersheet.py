#!/usr/bin/env python
import pandas as pd
import re
import sys

def is_valid_sequence(sequence):
    # Check if the input is a valid DNA sequence, including all IUPAC degenerate bases
    return bool(re.match(r'^[ACGTURYSWKMBDHVNacgturyswkm­­bdhvn]*$', sequence))

def check_and_normalize_column_names(df):
    # Remove leading and trailing spaces from column names
    df.columns = df.columns.str.strip()
    # Check if column names are 'fwd_primer' and 'rev_primer'
    if 'fwd_primer' in df.columns and 'rev_primer' in df.columns:
        df = df.rename(columns={'fwd_primer': 'forward_primer', 'rev_primer': 'reverse_primer'})
    return df

def check_primersheet(filename, output_filename):
    try:
        # Load the CSV file into a DataFrame
        primersheet = pd.read_csv(filename)

        # Debug: Print the column names
        print("Column names:", primersheet.columns)

        # Check and normalize column names
        primersheet = check_and_normalize_column_names(primersheet)

        # Check if the DataFrame has only one row
        if primersheet.shape[0] != 1:
            return False, "The primersheet should have only one row."

        # Check if the column names are as expected
        if not all(col in primersheet.columns for col in ['forward_primer', 'reverse_primer']):
            return False, "Column names in the primersheet should be 'forward_primer' and 'reverse_primer'."

        # Check if the values are sequences
        for col in ['forward_primer', 'reverse_primer']:
            if not is_valid_sequence(primersheet.at[0, col]):
                return False, f"The value in the column '{col}' of the primersheet is not a valid DNA sequence."

        # Save the adjusted primersheet as a CSV with the specified output filename
        primersheet.to_csv(output_filename, index=False)

        return True, f"Primersheet meets all the criteria and has been saved as '{output_filename}'."

    except Exception as e:
        return False, str(e)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_filename> <output_filename>")
        sys.exit(1)

    input_filename = sys.argv[1]
    output_filename = sys.argv[2]

    is_valid, message = check_primersheet(input_filename, output_filename)

    if is_valid:
        print("Primersheet is valid and saved as", output_filename)
    else:
        print("Primersheet is not valid:", message)
