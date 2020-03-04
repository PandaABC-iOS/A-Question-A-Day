问：如果利用Charles修改网络请求内容以及修改服务器返回内容？

###修改网络请求内容

有些时候为了调试服务器的接口，我们需要反复尝试不同参数的网络请求。Charles 可以方便地提供网络请求的修改和重发功能。只需要在以往的网络请求上点击右键，选择 “Compose”，即可创建一个可编辑的网络请求。

我们可以修改该请求的任何信息，包括 URL 地址、端口、参数等，之后点击 “Execute” 即可发送该修改后的网络请求。Charles 支持我们多次修改和发送该请求，这对于我们和服务器端调试接口非常方便。

### 修改服务器返回内容

有些时候我们想让服务器返回一些指定的内容，方便我们调试一些特殊情况。例如列表页面为空的情况，数据异常的情况，部分耗时的网络请求超时的情况等。如果没有 Charles，要服务器配合构造相应的数据显得会比较麻烦。这个时候，使用 Charles 相关的功能就可以满足我们的需求。

### Map

Charles 的 Map 功能分 Map Remote 和 Map Local 两种，顾名思义，Map Remote 是将指定的网络请求重定向到另一个网址请求地址，Map Local 是将指定的网络请求重定向到本地文件。在 Charles 的菜单中，选择 “Tools”–>“Map Remote” 或 “Map Local” 即可进入到相应功能的设置页面。

### Rewrite

rewrite功能重写对应的内容，主要可以对某些匹配请求的header、host、url、path、query param、response status、body进行rewrite。

[MapLocol 和 Rewrite用法](https://www.jianshu.com/p/dffca69070fc)

### breakPoints

上面提供的 Rewrite 功能最适合做批量和长期的替换，但是很多时候，我们只是想临时修改一次网络请求结果，这个时候，使用 Rewrite 功能虽然也可以达到目的，但是过于麻烦，对于临时性的修改，我们最好使用 Breakpoints 功能。Breakpoints 功能类似我们在 Xcode 中设置的断点一样，当指定的网络请求发生时，Charles 会截获该请求，这个时候，我们可以在 Charles 中临时修改网络请求的返回内容。

> 使用 Breakpoints 功能将网络请求截获并修改过程中，整个网络请求的计时并不会暂停，所以长时间的暂停可能导致客户端的请求超时。

[breakPoints用法](https://www.jianshu.com/p/7479866a1d8e)

