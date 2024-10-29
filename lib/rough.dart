// import pandas as pd
// import matplotlib.pyplot as plt
// import matplotlib.dates as mdates
// from datetime import datetime, timedelta
//
// # Define tasks and durations
// tasks = [
//
// {"Task": "Deployment", "Start": "2025-04-14", "Duration (days)": 2}
// {"Task": "Testing", "Start": "2025-04-07", "Duration (days)": 7},
// {"Task": "Development", "Start": "2024-12-08", "Duration (days)": 120},
// {"Task": "Design", "Start": "2024-12-01", "Duration (days)": 7},
// {"Task": "Analysis", "Start": "2024-11-24", "Duration (days)": 7},
// {"Task": "Requirement Gathering", "Start": "2024-11-17", "Duration (days)": 7},
// {"Task": "Planning", "Start": "2024-11-10", "Duration (days)": 7},
//
// ]
//
// # Create a DataFrame
// df = pd.DataFrame(tasks)
// df['Start'] = pd.to_datetime(df['Start'])
// df['End'] = df['Start'] + pd.to_timedelta(df['Duration (days)'], unit='days')
//
// # Plotting the Gantt chart
// fig, ax = plt.subplots(figsize=(10, 6))
//
// # Plot each task as a bar
// for i, task in df.iterrows():
// ax.barh(task["Task"], (task["End"] - task["Start"]).days, left=task["Start"], color="skyblue")
//
// # Formatting the chart
// ax.xaxis.set_major_locator(mdates.MonthLocator(interval=1))
// ax.xaxis.set_major_formatter(mdates.DateFormatter("%b %Y"))
// plt.xticks(rotation=45)
// plt.xlabel("Timeline")
// plt.ylabel("Tasks")
// plt.title("Gantt Chart")
//
// # Save the chart to Excel
// excel_path = '/mnt/data/Gantt_Chart_with_Chart.xlsx'
// with pd.ExcelWriter(excel_path, engine='xlsxwriter') as writer:
// df.to_excel(writer, index=False, sheet_name='Data')
// workbook = writer.book
// worksheet = writer.sheets['Data']
//
// # Insert the chart as an image
// image_path = '/mnt/data/Gantt_Chart.png'
// fig.savefig(image_path, bbox_inches='tight')
// worksheet.insert_image('G10', image_path)
//
// plt.close(fig)  # Close the plot to avoid displaying it here
//
// excel_path
