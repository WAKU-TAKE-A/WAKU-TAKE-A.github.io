# save_ai_outputs

save_ai_outputs.py

```
from pathlib import Path

# ============================================================
# Configuration (AI-editable)
# ============================================================

# Output directory name.
# Generative AI MAY change this value if needed.
OUTPUT_DIR_NAME = "contents_code"

# ------------------------------------------------------------
# Generated contents
# ------------------------------------------------------------
# Generative AI MAY output ONLY this dictionary when requested.
# Keys   : output file names
# Values : file contents (Markdown, code, documents, etc.)
#
# If this dictionary is empty, no files will be generated.
contents_code = {
    "hoge1.md": r"(hoge1 content)",
    "hoge2.md": r"(hoge2 content)",
}

# ============================================================
# Implementation (usually unchanged)
# ============================================================

def main():
    output_dir = Path(__file__).resolve().parent / OUTPUT_DIR_NAME
    output_dir.mkdir(exist_ok=True)

    for name, content in contents_code.items():
        path = output_dir / name
        path.write_text(content, encoding="utf-8")
        print(f"Generated: {path}")

if __name__ == "__main__":
    main()
```

生成AIに **ファイル出力用の Python スクリプトそのものを生成させる** ための、
最小構成テンプレートです。

「生成AIの出力をどう保存するか」ではなく、  
**「保存するためのスクリプトを、生成AIに作らせる」** ことを目的としています。

---

## コンセプト

生成AIは、

- Markdown
- ソースコード
- README
- 設計書

などを生成するのが得意です。

一方で、それらを **複数ファイルとして整理して保存する** となると、
人間がスクリプトを書いたり、コピーペーストしたりしがちです。

このリポジトリでは、その作業自体を生成AIに任せます。

---

## 想定している使い方（重要）

### 1. 生成AIにsave_ai_outputs.pyを提示する

プロンプトの例：

- 「この形式を使って、○○の結果をファイル出力するスクリプトを書いて」
- 「用途の説明、分かる？」

---

### 2. 生成AIに **スクリプトを生成させる**

生成AIは次のようなものを返します：

- `contents_code` に複数ファイル分の内容が書かれた Python スクリプト
- Markdown / コード / ドキュメントが埋め込まれた状態

👉 **人間はコピペするだけ（しかも一度のコピペで複数ファイルを生成できる）**

---

### 3. 生成されたスクリプトをそのまま実行する

```bash
python save_ai_outputs.py
````

すると、

* 指定されたファイル名
* 指定された内容

がまとめて出力されます。

---

## 想定用途

* 生成AIにヘルプや設計書一式を一括生成させる
* 複数のコードファイルを一括生成させる
* ドキュメント雛形をスクリプトとして受け取る
* 生成AIの出力を「実行可能な成果物」に変換する
