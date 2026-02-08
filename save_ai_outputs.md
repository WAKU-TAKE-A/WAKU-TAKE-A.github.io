from pathlib import Path

# ============================================================
# Configuration (AI-editable)
# ============================================================

# Output directory name.
OUTPUT_DIR_NAME = "contents_code"

# ------------------------------------------------------------
# Generated contents
# ------------------------------------------------------------
# 以下の辞書に、各ソースコードの完全な内容を格納しています。
contents_code = {
    "Form1.cs": r"""using System.Data;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;

namespace RunMultipleBatFiles;

public partial class Form1 : Form
{
    // パラメータ管理
    private readonly SettingParams _settings = new();

    // コマンドリスト管理
    private readonly ListCommand _lstCmd = new();

    // DOSコマンド実行クラス
    private readonly DosCommand _dos = new();

    // 環境変数用テキストボックスのペア
    private readonly Dictionary<TextBox, TextBox> _lstEnvVarBox = new();

    // キャンセル制御用トークンソース
    private CancellationTokenSource? _cts;

    // ログ出力に関連する定数定義（マジックナンバー排除）
    private const string LogDirectoryName = "logs";
    private const string LogFilePrefix = "ai_output_";
    private const string LogFileExtension = ".log";
    private const string LogTimestampFormat = "yyyyMMdd_HHmmss";
    private const string DefaultVersion = "0.0.0.0";

    public Form1()
    {
        InitializeComponent();

        // 共通エンコーディングの登録
        Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

        // フォーム全体でキー入力を受け取れるように設定（Ctrl+C検知用）
        this.KeyPreview = true;
        this.KeyDown += Form1_KeyDown;

        InitializeApp();
    }

    /// <summary>
    /// Ctrl+C による中断入力を検知します。
    /// </summary>
    private void Form1_KeyDown(object? sender, KeyEventArgs e)
    {
        if (e.Control && e.KeyCode == Keys.C)
        {
            if (_cts != null && !_cts.IsCancellationRequested)
            {
                txtStdOut.AppendText("\r\n[Ctrl+C] 中断要求を受け付けました。プロセスを停止します...\r\n");
                _cts.Cancel();
                e.SuppressKeyPress = true; // ビープ音などの標準挙動を抑制
            }
        }
    }

    private void InitializeApp()
    {
        var version = Assembly.GetExecutingAssembly().GetName().Version?.ToString() ?? DefaultVersion;
        this.Text = $"RunMultipleBatFiles {version}";

        txtLstCmd.Clear();
        txtStdOut.Clear();

        _lstEnvVarBox.Add(txtVar01, txtValue01);
        _lstEnvVarBox.Add(txtVar02, txtValue02);
        _lstEnvVarBox.Add(txtVar03, txtValue03);
        _lstEnvVarBox.Add(txtVar04, txtValue04);
        _lstEnvVarBox.Add(txtVar05, txtValue05);
        _lstEnvVarBox.Add(txtVar06, txtValue06);
        _lstEnvVarBox.Add(txtVar07, txtValue07);
        _lstEnvVarBox.Add(txtVar08, txtValue08);
        _lstEnvVarBox.Add(txtVar09, txtValue09);
        _lstEnvVarBox.Add(txtVar10, txtValue10);
    }

    protected override async void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        try
        {
            _settings.ReadXml();
            await _lstCmd.ReadTxtAsync();

            _settings.UpdateUiFromEnvVars(_lstEnvVarBox);
            txtLstCmd.Text = _lstCmd.Content;
            tabCntrl.SelectedTab = pageList;

            if (!string.IsNullOrWhiteSpace(_settings.CurrentDirectory))
            {
                Environment.CurrentDirectory = _settings.CurrentDirectory;
            }
            txtCD.Text = Environment.CurrentDirectory;

            chkIgnoreStdErr.Checked = _settings.IgnoreStdErr;
            chkEnableUtf8Encoding.Checked = _settings.EnableUtf8Encoding;
        }
        catch (Exception ex)
        {
            ShowError(ex);
        }
    }

    private void bttnSelect_Click(object sender, EventArgs e)
    {
        using var fbd = new FolderBrowserDialog();
        fbd.InitialDirectory = Environment.CurrentDirectory;

        if (fbd.ShowDialog() == DialogResult.OK)
        {
            Environment.CurrentDirectory = fbd.SelectedPath;
            txtCD.Text = fbd.SelectedPath;
        }
    }

    private async void bttnRun_Click(object sender, EventArgs e)
    {
        try
        {
            // UIの状態をクラスに同期
            _lstCmd.Content = txtLstCmd.Text;
            _settings.CurrentDirectory = txtCD.Text;
            _settings.IgnoreStdErr = chkIgnoreStdErr.Checked;
            _settings.EnableUtf8Encoding = chkEnableUtf8Encoding.Checked;
            _settings.SetEnvVarsFromUi(_lstEnvVarBox);

            // 実行中のUI制限
            bttnRun.Enabled = false;
            this.AllowDrop = false;
            txtStdOut.Clear();
            tabCntrl.SelectedTab = pageStdOut;

            // キャンセル制御用トークンの発行
            _cts = new CancellationTokenSource();

            var activeSettings = _settings.Clone();

            // プロセス環境変数の更新
            UpdateProcessEnvironmentVariables(activeSettings);

            // コマンド実行（トークンを渡す）
            await RunCommandsAsync(activeSettings, _cts.Token);
        }
        catch (OperationCanceledException)
        {
            txtStdOut.AppendText("\r\nユーザーによって実行が中断されました。\r\n");
        }
        catch (Exception ex)
        {
            ShowError(ex);
        }
        finally
        {
            txtStdOut.AppendText("\r\nDone.\r\n");
            
            // AI出力を保存
            SaveAiOutputs(txtStdOut.Text);

            bttnRun.Enabled = true;
            this.AllowDrop = true;
            _cts?.Dispose();
            _cts = null;
        }
    }

    /// <summary>
    /// 実行ログを指定のディレクトリに保存します。
    /// </summary>
    private void SaveAiOutputs(string content)
    {
        try
        {
            string dirPath = Path.Combine(AppContext.BaseDirectory, LogDirectoryName);
            if (!Directory.Exists(dirPath))
            {
                Directory.CreateDirectory(dirPath);
            }

            string timestamp = DateTime.Now.ToString(LogTimestampFormat);
            string fileName = $"{LogFilePrefix}{timestamp}{LogFileExtension}";
            string filePath = Path.Combine(dirPath, fileName);

            File.WriteAllText(filePath, content, Encoding.UTF8);
        }
        catch (Exception ex)
        {
            // ログ保存失敗時はメッセージボックスで通知
            MessageBox.Show($"ログの保存に失敗しました: {ex.Message}", "Save Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private void UpdateProcessEnvironmentVariables(SettingParams settings)
    {
        for (int i = 0; i < settings.GetNum(); i++)
        {
            if (!string.IsNullOrWhiteSpace(settings.Variables[i]))
            {
                Environment.SetEnvironmentVariable(settings.Variables[i], settings.Values[i], EnvironmentVariableTarget.Process);
            }
        }
    }

    private async Task RunCommandsAsync(SettingParams settings, CancellationToken ct)
    {
        var commands = string.IsNullOrWhiteSpace(txtLstCmd.Text)
            ? Array.Empty<string>()
            : Regex.Split(txtLstCmd.Text, "\r\n|\n");

        if (commands.Length == 0)
        {
            txtStdOut.Text = "List is empty.";
            return;
        }

        foreach (var cmd in commands)
        {
            if (string.IsNullOrWhiteSpace(cmd)) continue;

            // キャンセル要求がないかチェック
            ct.ThrowIfCancellationRequested();

            // システム・ユーザーパスをマージ
            RefreshPathEnvironmentVariable();

            txtStdOut.AppendText($"\r\n>> {cmd}\r\n");
            ScrollToBottom();

            try
            {
                await _dos.RunOneLineAsync(cmd, settings.IgnoreStdErr, settings.EnableUtf8Encoding, ct);

                string output = _dos.StandardOutput
                    .Replace("\n", "\r\n")
                    .Replace("\r\r", "\r");

                output = Regex.Replace(output, @"\x1B\[[^@-_]*[A-Za-z]", "");
                txtStdOut.AppendText(output);
            }
            catch (OperationCanceledException)
            {
                throw; // 上位へ再送
            }
            catch (Exception ex)
            {
                txtStdOut.AppendText($"\r\nException in command execution:\r\n{ex.Message}\r\n");
                break;
            }

            ScrollToBottom();
        }
    }

    private void RefreshPathEnvironmentVariable()
    {
        string currentPath = Environment.GetEnvironmentVariable("path", EnvironmentVariableTarget.Process) ?? "";
        string systemPath = Environment.GetEnvironmentVariable("path", EnvironmentVariableTarget.Machine) ?? "";
        string userPath = Environment.GetEnvironmentVariable("path", EnvironmentVariableTarget.User) ?? "";

        var pathSet = currentPath.Split(';', StringSplitOptions.RemoveEmptyEntries).ToList();
        var updatePaths = $"{systemPath};{userPath}".Split(';', StringSplitOptions.RemoveEmptyEntries);

        foreach (var p in updatePaths)
        {
            if (!pathSet.Contains(p, StringComparer.OrdinalIgnoreCase))
            {
                pathSet.Add(p);
            }
        }
        Environment.SetEnvironmentVariable("path", string.Join(";", pathSet), EnvironmentVariableTarget.Process);
    }

    private void ScrollToBottom()
    {
        txtStdOut.SelectionStart = txtStdOut.Text.Length;
        txtStdOut.ScrollToCaret();
    }

    private void ShowError(Exception ex)
    {
        tabCntrl.SelectedTab = pageStdOut;
        txtStdOut.AppendText($"\r\nException Details:\r\n{ex}\r\n");
    }

    private void Form1_DragEnter(object sender, DragEventArgs e)
    {
        if (e.Data?.GetDataPresent(DataFormats.FileDrop) == true)
            e.Effect = DragDropEffects.All;
    }

    private async void Form1_DragDrop(object sender, DragEventArgs e)
    {
        if (e.Data?.GetData(DataFormats.FileDrop) is not string[] files) return;

        try
        {
            foreach (var file in files)
            {
                string ext = Path.GetExtension(file).ToLower();

                if (ext == ".txt")
                {
                    await _lstCmd.ReadTxtAsync(file);
                    txtLstCmd.Text = _lstCmd.Content;
                    tabCntrl.SelectedTab = pageList;
                }
                else if (ext == ".xml")
                {
                    _settings.ReadXml(file);
                    _settings.UpdateUiFromEnvVars(_lstEnvVarBox);

                    if (!string.IsNullOrWhiteSpace(_settings.CurrentDirectory))
                        Environment.CurrentDirectory = _settings.CurrentDirectory;

                    txtCD.Text = Environment.CurrentDirectory;
                    chkIgnoreStdErr.Checked = _settings.IgnoreStdErr;
                    chkEnableUtf8Encoding.Checked = _settings.EnableUtf8Encoding;
                    tabCntrl.SelectedTab = pageSettings;
                }
            }
        }
        catch (Exception ex)
        {
            ShowError(ex);
        }
    }
}""",
    "DosCommand.cs": r"""using System.Diagnostics;
using System.Text;

namespace RunMultipleBatFiles;

public class DosCommand
{
    public string StandardOutput { get; private set; } = "";

    /// <summary>
    /// 指定されたコマンドを非同期で実行します。
    /// CancellationToken により、プロセスツリー全体を強制終了することが可能です。
    /// </summary>
    public async Task<bool> RunOneLineAsync(string command, bool ignoreStdErr, bool enableUtf8Encoding, CancellationToken ct)
    {
        var encoding = enableUtf8Encoding ? Encoding.UTF8 : Encoding.GetEncoding("shift_jis");

        using var p = new Process();
        p.StartInfo.FileName = Environment.GetEnvironmentVariable("ComSpec") ?? "cmd.exe";
        p.StartInfo.Arguments = $"/c {command}";
        p.StartInfo.UseShellExecute = false;
        p.StartInfo.RedirectStandardOutput = true;
        p.StartInfo.RedirectStandardError = true;
        p.StartInfo.CreateNoWindow = true;
        p.StartInfo.StandardOutputEncoding = encoding;
        p.StartInfo.StandardErrorEncoding = encoding;

        if (!p.Start()) return false;

        // トークンがキャンセルされたら、即座にプロセスツリーを強制終了する
        using var registration = ct.Register(() =>
        {
            try
            {
                if (!p.HasExited)
                {
                    // 木構造全体（子プロセス含む）を強制終了
                    p.Kill(true);
                }
            }
            catch (InvalidOperationException)
            {
                // すでにプロセスが終了している場合の例外は無視
            }
            catch (Exception)
            {
                // その他の例外も無視
            }
        });

        // 出力を非同期で読み取る
        var outTask = p.StandardOutput.ReadToEndAsync(ct);
        var errTask = p.StandardError.ReadToEndAsync(ct);

        try
        {
            await p.WaitForExitAsync(ct);
        }
        catch (OperationCanceledException)
        {
            StandardOutput = "\r\n[中断信号によりプロセスが終了しました]\r\n";
            throw; // 上位の呼び出し元に通知
        }

        StandardOutput = await outTask;
        string err = await errTask;

        if (!ignoreStdErr && !string.IsNullOrEmpty(err))
        {
            throw new Exception(err);
        }

        return true;
    }
}""",
    "SettingParams.cs": r"""using System.Text;
using System.Xml.Serialization;

namespace RunMultipleBatFiles;

/// <summary>
/// パラメータを管理するクラス
/// </summary>
public class SettingParams
{
    // マジックナンバーを排除するための定数定義
    public const int MaxVariableCount = 10;

    [XmlIgnore]
    public readonly string DefaultXmlPath = Path.Combine(AppContext.BaseDirectory, "RunMultipleBatFiles.xml");

    // 固定個数の環境変数ペア
    public string[] Variables { get; set; } = new string[MaxVariableCount];
    public string[] Values { get; set; } = new string[MaxVariableCount];

    public string CurrentDirectory { get; set; } = string.Empty;
    public bool IgnoreStdErr { get; set; }
    public bool EnableUtf8Encoding { get; set; }

    public SettingParams()
    {
        // 配列の中身を空文字で初期化
        for (int i = 0; i < MaxVariableCount; i++)
        {
            Variables[i] = string.Empty;
            Values[i] = string.Empty;
        }
    }

    /// <summary>
    /// 現在のインスタンスのディープコピーを作成します
    /// </summary>
    public SettingParams Clone()
    {
        var clone = new SettingParams
        {
            CurrentDirectory = this.CurrentDirectory,
            IgnoreStdErr = this.IgnoreStdErr,
            EnableUtf8Encoding = this.EnableUtf8Encoding
        };
        Array.Copy(this.Variables, clone.Variables, MaxVariableCount);
        Array.Copy(this.Values, clone.Values, MaxVariableCount);
        return clone;
    }

    /// <summary>
    /// XMLファイルから設定を読み込みます
    /// </summary>
    public void ReadXml(string? path = null)
    {
        try
        {
            string fileName = string.IsNullOrEmpty(path) ? DefaultXmlPath : path;
            var serializer = new XmlSerializer(typeof(SettingParams));

            if (!File.Exists(fileName))
            {
                using var sw = new StreamWriter(fileName, false, new UTF8Encoding(false));
                serializer.Serialize(sw, this);
            }
            else
            {
                using var sr = new StreamReader(fileName, new UTF8Encoding(false));
                if (serializer.Deserialize(sr) is SettingParams tmp)
                {
                    this.Variables = tmp.Variables;
                    this.Values = tmp.Values;
                    this.CurrentDirectory = tmp.CurrentDirectory;
                    this.IgnoreStdErr = tmp.IgnoreStdErr;
                    this.EnableUtf8Encoding = tmp.EnableUtf8Encoding;
                }
            }
        }
        catch (Exception)
        {
            throw;
        }
    }

    /// <summary>
    /// UI（TextBoxの辞書）から値をクラスにセットします
    /// </summary>
    public void SetEnvVarsFromUi(Dictionary<TextBox, TextBox> lstEnvVarBox)
    {
        if (lstEnvVarBox == null || lstEnvVarBox.Count != MaxVariableCount)
        {
            throw new ArgumentException($"テキストボックスの数は {MaxVariableCount} である必要があります。");
        }

        int i = 0;
        foreach (var item in lstEnvVarBox)
        {
            Variables[i] = item.Key.Text;
            Values[i] = item.Value.Text;
            i++;
        }
    }

    /// <summary>
    /// クラスの値をUI（TextBoxの辞書）に反映させます
    /// </summary>
    public void UpdateUiFromEnvVars(Dictionary<TextBox, TextBox> lstEnvVarBox)
    {
        if (lstEnvVarBox == null || lstEnvVarBox.Count != MaxVariableCount)
        {
            throw new ArgumentException($"テキストボックスの数は {MaxVariableCount} である必要があります。");
        }

        int i = 0;
        foreach (var item in lstEnvVarBox)
        {
            item.Key.Text = Variables[i];
            item.Value.Text = Values[i];
            i++;
        }
    }

    public int GetNum() => Variables.Length;
}""",
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