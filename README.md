# dev-tools

Collection of developer scripts, files, etc, for improving the developer process.

You can use `bootstrap` to "install" some of these tools, e.g., the `pre-commit` hook.

Note that we currently use `ln -s` to "install" git hooks rather than just making a copy so that we can actually update it in the repository and everyone will benefit from the update).
Also we "install" `.gitignore` and `.clang-format` files in the `root` directory to ignore all unused files and to have your code well-formatted.

#### ***So, before you start the work with the current repo we recommend you to run this file with the following command in the root directory (Linux & macOS):***

```
cd dev-tools && ./bootstrap
```