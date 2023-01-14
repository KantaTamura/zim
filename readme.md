## zim - a simple text editor made with zig

### 使用法

```
> zig run src/main.zig
```

### 機能

標準入力を受け取り，標準入力に書き出す

'q'が入力された場合終了する

#### Raw Mode

以下の属性を切っている．

 - `echo属性` : キーボードの入力を標準出力に表示する
 - `icanon属性` : 行ごとに入力を受け付ける
 - `isig属性` : Ctrl-CでSIGINT，Ctrl-ZでSIGQUITを生成する
 - `ixon属性` : 開始 / 停止出力制御を行う

```
fn enableRawMode() !void {
    original_termios = try os.tcgetattr(stdin_handle);
    var raw = original_termios;
    raw.iflag &= ~(os.linux.BRKINT | os.linux.ICRNL | os.linux.INPCK | os.linux.ISTRIP | os.linux.IXON);
    raw.oflag &= ~(os.linux.OPOST);
    raw.cflag |=  (os.linux.CS8);
    raw.lflag &= ~(os.linux.ECHO | os.linux.ICANON | os.linux.IEXTEN | os.linux.ISIG);
    raw.cc[VMIN]  = 0;
    raw.cc[VTIME] = 1;
    try os.tcsetattr(stdin_handle, os.TCSA.FLUSH, raw);
}
```

プログラム終了時にターミナル属性をもとに戻すために初期のターミナル属性を`original_termios`に保存する．
メインのプログラム中に`defer disableRawMode()`と記述することでプログラム終了時に自動的に実行できる．

```
fn disableRawMode() void {
    os.tcsetattr(stdin_handle, os.TCSA.FLUSH, original_termios) catch |err| {
        std.debug.print("{}", .{err});
    };
}
```

### 参考文献

[Build Your Own Text Editor](https://viewsourcecode.org/snaptoken/kilo/ "kilo editor")
