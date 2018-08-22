
<map version="0.9.0">
    <node TEXT="9.6 可散列的对象" FOLDED="false" POSITION="right" ID="5b7d251c875cc671f415bbf4" X_COGGLE_POSX="0" X_COGGLE_POSY="0">
        <edge COLOR="#b4b4b4" />
        <font NAME="Helvetica" SIZE="17" />
        <node TEXT="什么是可散列的数据类型" FOLDED="false" POSITION="right" ID="f89bde9fc8990de229113f6bcb124d4d">
            <edge COLOR="#67d7c4" />
            <font NAME="Helvetica" SIZE="15" />
        </node>
        <node TEXT="对象要不可变，需要把所有属性设为只读" FOLDED="false" POSITION="right" ID="2ae4772ca34ec7b0c09bda85123524cd">
            <edge COLOR="#9ed56b" />
            <font NAME="Helvetica" SIZE="15" />
            <node TEXT="Example:
Vector:
    def __init__(self, x, y):
        self.__x = x 
        self.__y = y
    @property
     def x(self):
          return self.__x
      @property
      def y(self):
           return self.__y

" FOLDED="false" POSITION="right" ID="4e51f5d8e807df532f10f7c6ed081e5f">
                <edge COLOR="#a3d86e" />
                <font NAME="Helvetica" SIZE="13" />
            </node>
        </node>
        <node TEXT="如果有标量属性，还要实现\__int\__和\__float\__方法" FOLDED="false" POSITION="right" ID="2cc76e2fabe4ef5ca14760fac4f851a5">
            <edge COLOR="#efa670" />
            <font NAME="Helvetica" SIZE="15" />
        </node>
        <node TEXT="可以添加到set中" FOLDED="false" POSITION="left" ID="3effcad67be006f5693fc8bcc8131f5a">
            <edge COLOR="#ebd95f" />
            <font NAME="Helvetica" SIZE="15" />
        </node>
        <node TEXT="需要实现：
\__hash\__
\__eq\__
" FOLDED="false" POSITION="right" ID="fcfffb2237bb3f8690994e76283de676">
            <edge COLOR="#7aa3e5" />
            <font NAME="Helvetica" SIZE="13" />
        </node>
    </node>
</map>