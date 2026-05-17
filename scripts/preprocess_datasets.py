import pandas as pd
import os

# Simple preprocessing for coding datasets — looks for CSV files in datasets/coding
coding_dir = os.path.join(os.path.dirname(__file__), '..', 'datasets', 'coding')
coding_dir = os.path.normpath(coding_dir)

if not os.path.exists(coding_dir):
    print(f"Coding dataset directory not found: {coding_dir}")
else:
    csv_files = [f for f in os.listdir(coding_dir) if f.lower().endswith('.csv')]
    if not csv_files:
        print(f"No CSV files found in {coding_dir}. Place coding datasets as CSV for preprocessing.")
    else:
        csv_path = os.path.join(coding_dir, csv_files[0])
        print(f"Processing coding dataset: {csv_path}")
        df = pd.read_csv(csv_path, encoding='utf-8', on_bad_lines='skip')
        print(f"Raw rows loaded: {len(df)}")
        # Attempt to detect common columns
        if 'question' in df.columns and 'answer' in df.columns:
            out_df = df[['question', 'answer']].rename(columns={'question': 'question_text', 'answer': 'answer'})
        else:
            # fallback: use first text-like column as question
            text_cols = [c for c in df.columns if df[c].dtype == object]
            if not text_cols:
                print('No text columns found to extract questions. Inspect the CSV file.')
            else:
                qcol = text_cols[0]
                out_df = df[[qcol]].rename(columns={qcol: 'question_text'})

        if 'out_df' in locals():
            out_df = out_df.replace('', None)
            out_df = out_df.dropna(how='all')
            if len(out_df) == 0:
                print('No valid rows after cleaning. Check dataset content.')
            else:
                out_path = os.path.join(coding_dir, 'train_clean.jsonl')
                out_df.to_json(out_path, orient='records', lines=True)
                print(f'Preprocessed coding dataset saved to {out_path} with {len(out_df)} rows')