Contribution guidelines
=====================

This guide aims to help developers working on this repository.

Filing issues
---------------------------------

File issues using the standard [Github issue tracker][1] for
the repository. Before you submit a new issue, we recommend that you
search the list of issues to see if anyone already submitted a similar
issue.

Contributing patches
---------------------------------

### Making changes to runtime scripts

The Docker images created from this repository contain several runtime scripts
that are executed from the image entrypoint / default command. These scripts are
located under `${IMAGE_VERSION}/root/`.

As a suggestion, start making changes to files of a single image version, e.g.,
the latest one, and then run tests for that image:

```bash
make test VERSION=3.2 SKIP_SQUASH=1
```

By default, the last step in the image build process is to squash the output
image into less layers, optimizing image size for distribution. However, unless
specifically testing that this squash process is working, you don't need to
squash images in development, and can save some precious time with consecutive
rebuilds as you work in the image contents.

The `SKIP_SQUASH=1` option disables image squashing, so that building and
rebuilding images locally should take less time.

Setting `VERSION=3.2` equally saves development time. Instead of building every
image version, only the version you are working on will be built.

The tests run via `make test` cover some basic usage patterns of the images.
Often times, some manual testing is required while making changes to the scripts
that are copied into the images. For instance, you can build and rebuild a
specific image (without running tests) with this command:

```bash
make VERSION=3.2 SKIP_SQUASH=1
```

When you are done with your changes, you probably want to [change all other
image versions without copy-paste](#changing-all-images-without-copy-paste).

### Changing all images without copy-paste

We keep the multiple files for the different image versions in sync. Here is a
tip on how to use `git` commands to automatically apply patches targeting one
image to all the others, without incurring in manually editing each copy of each
modified file.

Supposing that changes were made to files in the 3.2 directory, we can then
apply those changes to all other images:

```bash
for version in 2.4 2.6 3.0-upg; do
  git diff -- 3.2 | git apply -p2 --directory ${version} --reject
done
```

Depending on the changes and the surrounding context, the patch may not apply
cleanly. In that case, Git will create `*.rej` files with the changes that could
not be applied.

You can show them all with:

```bash
find -name '*.rej' -exec cat {} \;
```

Fix the differences manually, then delete the `*.rej` files.

Testing
---------------------------------

Eash version of MongoDB maintains their own test cases within `test/`. To run the tests, run:

### Unit Tests

To run all tests during the development cycle:

```
make test
```

To run specific tests, use one of the following methods:

* Run all tests on a single version of MongoDB.

  ```
  make test VERSION=<mongodb-version>
  ```
* Run all tests on a single base image version of MongoDB.

  ```
  make test VERSION=<mongodb-version> TARGET=<base-image>
  ```

### OpenShift Integration Tests

To run all OpenShift tests during the development cycle:

```
make test-openshift
```

To run specific OpenShift tests, use one of the following methods:

* Run all OpenShift tests on a single version of MongoDB.

  ```
  make test-openshift VERSION=<mongodb-version>
  ```
* Run all OpenShift tests on a single base image version of MongoDB.

  ```
  make test-openshift VERSION=<mongodb-version> TARGET=<base-image-os>
  ```

Additional comments
---------------------------------

**Review the changes** before committing to make sure the patch to all versions
make sense.

### Git commands
- Sometimes it may be useful to ignore part of the context passing the `-C<n>` flag to `git apply`.
- Read `git help diff` and `git help apply` for details about the flags used here and further insights on how to combine them.

### Other
Sometimes it is also useful to use a graphical diff tool such as [Meld][2] for a final verification, or working side-by-side on the parts that actually differ and that cannot the copied over automatically.

[1]: https://github.com/sclorg/mongodb-container/issues
[2]: http://meldmerge.org/
