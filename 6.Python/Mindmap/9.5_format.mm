
<map version="0.9.0">
    <node TEXT="9.5 format" FOLDED="false" POSITION="right" ID="5b7d1820875cc68f4f1588ba" X_COGGLE_POSX="0" X_COGGLE_POSY="0">
        <edge COLOR="#b4b4b4" />
        <font NAME="Helvetica" SIZE="17" />
        <node TEXT="str.format()" FOLDED="false" POSITION="right" ID="a93a4b7a5e79ad7c86d9afa65e975c24">
            <edge COLOR="#67d7c4" />
            <font NAME="Helvetica" SIZE="15" />
            <node TEXT=": 表示格式说明符，在他右边是格式说明
例如： BRL = '{rate:0.2f} USD'.format(rate=brl)
0.2f 格式说明符
rate 是字段名" FOLDED="false" POSITION="right" ID="cf121a78ca817ad14e0e9f0ad90974ad">
                <edge COLOR="#6cd6c3" />
                <font NAME="Helvetica" SIZE="13" />
            </node>
            <node TEXT="" FOLDED="false" POSITION="right" ID="15af62114f42514f337f29ccf8eed8ec">
                <edge COLOR="#64d6c1" />
                <font NAME="Helvetica" SIZE="13" />
            </node>
            <node TEXT="'{0.mass:5.3e}" FOLDED="false" POSITION="right" ID="dd3c35b8fce0c9b50a843daf4209eddf">
                <edge COLOR="#6fd7c4" />
                <font NAME="Helvetica" SIZE="13" />
            </node>
        </node>
        <node TEXT="format_spec:格式说明书" FOLDED="false" POSITION="left" ID="6d4177e5d515e3124dc9489118c419d1">
            <edge COLOR="#9ed56b" />
            <font NAME="Helvetica" SIZE="15" />
            <node TEXT="b: 二进制的int类型
x:十六进制的int类型
f:表示浮点数
%:表示百分数形式
" FOLDED="false" POSITION="left" ID="9d049971a1ec01aae29304238a8b01c4">
                <edge COLOR="#a1d56d" />
                <font NAME="Helvetica" SIZE="13" />
                <node TEXT="format(42, 'b')" FOLDED="false" POSITION="left" ID="1a1702e83aaf138735e95ba3458f5394">
                    <edge COLOR="#9fd169" />
                    <font NAME="Helvetica" SIZE="12" />
                </node>
                <node TEXT="&gt;&gt;&gt; format(2/3, '.1%')
'66.7%'
" FOLDED="false" POSITION="left" ID="7b56fc136beae78a84a54fd67635ea8d">
                    <edge COLOR="#9fd367" />
                    <font NAME="Helvetica" SIZE="12" />
                </node>
                <node TEXT="&gt;&gt;&gt; format(datetime.now(), '%H:%M:%S')
'18:49:05'" FOLDED="false" POSITION="left" ID="fd8fd65c08c022c3f3a231b1a0583f8c">
                    <edge COLOR="#a9d777" />
                    <font NAME="Helvetica" SIZE="12" />
                </node>
            </node>
        </node>
        <node TEXT="built-in format" FOLDED="false" POSITION="right" ID="6335b036230bd081a7c865b4b022971c">
            <edge COLOR="#7aa3e5" />
            <font NAME="Helvetica" SIZE="15" />
            <node TEXT="example:
format(brl, '0.4f')" FOLDED="false" POSITION="right" ID="1597ced9878a27338466d63306c719da">
                <edge COLOR="#83abe8" />
                <font NAME="Helvetica" SIZE="13" />
            </node>
        </node>
        <node TEXT="特殊方法：\__format\__" FOLDED="false" POSITION="right" ID="ee72842f09b1a7013f4177215fe833a6">
            <edge COLOR="#ebd95f" />
            <font NAME="Helvetica" SIZE="15" />
            <node TEXT="对可迭代的类实现特殊方法\__format\__,可以实现对对象的每个元素进行format，
def __format__(self, fmt_spec=''):
    components = (format(c, fmt_spec) for c in self)
    return '({}, {})'.format(*components) " FOLDED="false" POSITION="right" ID="3a8f3b8c3f83bc99a085f72739cc9a58">
                <edge COLOR="#e9d55d" />
                <font NAME="Helvetica" SIZE="13" />
            </node>
        </node>
    </node>
</map>