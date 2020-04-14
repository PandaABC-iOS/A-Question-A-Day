# Git中如何查看两次提交之间的文件修改

有时候，我们希望看一看，相隔一段时间内，代码中做的所有修改。应该怎么办呢？

## 实现方法

在终端中

如果想看新旧两次提交间，所有的文件详细内容改动

```
git diff old-commit-id new-commit-id
```

如果不想看具体的修改内容，只想查看哪些文件做了改动，可以使用

```
git diff —name-only old-commit-id new-commit-id
```

如果只想要查看包含某个路径的文件变动

```
git diff --name-only old-commit-id new-commit-id | grep iPadN
```

如果在上面的基础上，还想要排除掉某些文件或路径

```
git diff --name-only old-commit-id new-commit-id | grep iPadN | grep -v iPadN.xcassets
```

