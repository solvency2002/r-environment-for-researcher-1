# Back-Translation Report

Stage A verification artifact (code-review-companion skill).
Generated: 2026-02-26

---

## 00_setup.R

1. プロジェクトのパス設定ファイル (`_project_config.R`) を読み込む
2. `tidyverse`, `here` を読み込む。`pROC`（ROC/AUC用）, `irr`（Kappa用）はオプションで利用可能性を確認
3. 乱数シードを `42` に設定
4. 出力ディレクトリ（`output/`, `figures/`, `tables/`, `verification/`）が存在しなければ作成
5. R セッション情報（バージョン、パッケージ一覧）を `session_info.txt` に記録

**@plan_id**: G0A-1, G0A-2, G0A-3

---

## 01_data_load_clean.R

1. `data/processed/` から 3 つの CSV を `readr::read_csv()` で読み込み:
   - `chatgpt_cases_cleaned.csv` → `df_cases`
   - `diagnostic_accuracy_600.csv` → `df_diag`
   - `all_reviews.csv` → `df_reviews`
2. 行数を検証: 150, 600, 300 行（不一致なら `stopifnot` でエラー停止）
3. 変数の型を検証: `answer_correct_bool` は logical, カテゴリ変数は character
4. 因子変換:
   - `cognitive_load_std` → 順序付き因子 (Low < Moderate < High)
   - `quality_answer_std` → 因子 (3 水準)
   - `diagnostic_result` → 因子 (4 水準)
5. 各データフレームの欠測値を `is.na()` で確認し報告
6. `df_cases` のデータ構造を `str()` で出力

**@plan_id**: G0B-1, G0B-2, G0B-3, G0B-4

---

## 02_descriptives.R

1. `df_cases` から `answer_correct_bool`, `cognitive_load_std`, `quality_answer_std` の度数・割合を算出
2. 3 変数を統合した Table 1 形式のデータフレームを作成
3. `output/tables/table1_descriptives.csv` に保存

**@plan_id**: G1-1

---

## 03_primary_analysis.R

1. `df_cases` から正答数 (`sum(answer_correct_bool)`) と正答率を算出
2. 論文報告値との比較表を作成
3. `output/tables/table2_primary_outcome.csv` に保存
4. 結果を `qa_results` に格納（QA検証用）

**@plan_id**: G2A-1

---

## 04_diagnostic_accuracy.R

1. `df_diag` から TP/FP/TN/FN の件数を集計
2. 診断精度指標を算出: Overall Accuracy, Precision, Sensitivity, Specificity
3. `pROC::roc()` で AUC を算出（パッケージ不在時はスキップ）
4. 感度分析: AUC の手動計算 `(sensitivity + specificity) / 2` と `pROC` の比較
5. 論文報告値との比較表を `output/tables/table3_diagnostic_metrics.csv` に保存
6. 結果を `qa_results` に格納

**@plan_id**: G2B-1, G2B-2, G2C-2

---

## 05_secondary_outcomes.R

1. `cognitive_load_std` の度数分布を算出し論文値と比較
2. 感度分析: High=11 vs High=12 による割合変動を計算・報告
3. `quality_answer_std` の度数分布を算出し論文値と比較
4. `all_reviews.csv` からレビュアー R1/R2 の評価を wide 形式に変換
5. `irr::kappa2()` で 3 変数の Cohen's Kappa を算出
6. 合成データの制約（R1≡R2 → κ=1.0）を注記
7. 結果を `qa_results` に格納

**@plan_id**: G2B-3, G2B-4, G2B-5, G2C-1

---

## 06_figures_tables.R

1. 共通テーマ `theme_study` を定義（minimal + bold タイトル）
2. Figure 1: 正答/誤答の棒グラフ → PNG+PDF 保存
3. Figure 2: TP/FP/TN/FN の 2×2 ヒートマップ → PNG+PDF 保存
4. Figure 3: ROC 曲線（`pROC` 使用）→ PNG+PDF 保存
5. Figure 4: 認知負荷の棒グラフ (Low/Moderate/High) → PNG+PDF 保存
6. Figure 5: 医学情報品質の棒グラフ → PNG+PDF 保存

**@plan_id**: G3-1, G3-2, G3-3, G3-4, G3-5

---

## run_all.R

1. `qa_results` リストを初期化
2. 00_setup.R → 01 → 02 → 03 → 04 → 05 → 06 を順次 `source()`
3. データ整合性結果 (行数) を `qa_results` に追加
4. `qa_results` を `qa_inputs.json` 形式に変換し `output/verification/` に保存
5. `99_verify_data.R` を呼び出して Stage B 検証を実行

---

## 99_verify_data.R

1. `qa_inputs.json` を読み込み
2. `verification_config.yml` の `key_results` と突合（id + metric で結合）
3. 許容範囲内なら PASS, 超過なら FAIL, 欠損なら FAIL
4. `qa_report.md` を生成（比較表 + サマリ）
5. データファイル・出力ファイルの存在確認
6. `sample_verification_report.md` を生成
7. `on_failure: error` の場合は `stop()` で中断
