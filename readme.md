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
    const handler = io.getStdIn().handle;
    var raw = try os.tcgetattr(handler);
    raw.lflag &= ~(os.linux.ECHO);
    try os.tcsetattr(handler, os.TCSA.FLUSH, raw);
}
```

### 参考文献

[Build Your Own Text Editor](https://viewsourcecode.org/snaptoken/kilo/ "kilo editor")
