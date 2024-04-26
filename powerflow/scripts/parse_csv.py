import pandas as pd
import matplotlib.pyplot as plt
import argparse

def calculate_average_power(csv_file):
    # Read the CSV file
    data = pd.read_csv(csv_file)

    # Calculate the average of the power consumption columns
    average_power = {
        'total [W]': data['total [nW]'].mean(),
        'leakage [W]': data['leakage [nW]'].mean(),
        'internal [W]': data['internal [nW]'].mean(),
        'switching [W]': data['switching [nW]'].mean()
    }
    return average_power

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=
        'This script calculates the average power consumption from a CSV file')
    parser.add_argument('csv_file', type=str,
        help='CSV file containing power consumption data.')
    args = parser.parse_args()
    csv_path = args.csv_file
    average_power = calculate_average_power(csv_path)
    print('Average Power Consumption:')
    print(average_power)