## zim - a simple text editor made with zig

### 使用法

```
> zig run src/main.zig
```

### 機能

標準入力を受け取る簡単なプログラム

EOFか'q'が入力された場合終了する

#### Raw Mode

ターミナルの`echo属性`(キーボードの入力を表示する)を切る

```
fn enableRawMode() !void {
    original_termios = try os.tcgetattr(stdin_handle);
    var raw = original_termios;
    raw.lflag &= ~(os.linux.ECHO);
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
