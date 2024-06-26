# python_install

WindowsでのPythonをインストールするためのバッチファイル

## コンセプト

Pythonは、使用したいライブラリなどに合わせたバージョンをインストールする必要があります。そのため、複数のバージョンのインストールや、使用しないバージョンのアンインストールを行う必要があります。通常のWindows版のPythonはインストーラーを使用するため、レジストリや環境変数の変更が行われてしまいます。

レジストリや環境変数の変更を行いたくないため、環境を汚さないでPythonをインストールするツールを作成しました。

## 使用方法

1. Pythonをインストールするフォルダーを作成し、そのフォルダーに`python_install.bat`を配置します。
2. コマンドプロンプトを起動して`python_install.bat`を実行します。インストールしたいバージョンが以下のように表示されるので、選択を行います。

```
D:\python_env>python_install.bat
1: 3.9.13
2: 3.10.11
3: 3.11.9
4: 3.12.3
バージョンを選択してください。(1-4) :
```

3. インストールが終了すると、以下のようなコメントが出力されます。

```
以後 Python 3.9.13 を使用する場合は、"D:\python_env\venv3_9_13\Scripts\activate" を実行してください。
"D:\python_env\3_9_13" に Python 3.9.13 をインストールしました。
```

Pythonは仮想環境venvで使用することを想定してインストールしているため、使用する場合は、仮想環境の有効化（例：`D:\python_env\venv3_9_13\Scripts\activate`）を実行して作業を行います。

VSCodeなどでは、仮想環境のpython.exeをインタープリタに選択することで、自動的に仮想環境を有効化した状態で開発ができます。

