[![Tuist badge](https://img.shields.io/badge/Powered%20by-Tuist-blue)](https://tuist.io)

# iOS App

This folder contains all the code of the iOS app.
`tuist` is used to handle dependencies and the Xcode project in general, More info here `https://docs.tuist.io/tutorial/get-started/`.

For `fastlane`, take a look at the `fastlane` directory and open the `INSTRUCTIONS.md` file (the `README.md` is auto-generated).

## Installation

```bash
# The xcodes CLI isn't required but convenient to handle different Xcode versions
$ brew install robotsandpencils/made/xcodes
# Install Tuist
$ curl -Ls https://install.tuist.io | bash
```

## How

At first you need to fetch all dependencies with `tuist`, then you can generate the Xcode project:

```bash
# Fetch all dependencies
$ tuist fetch
# Generate the Xcode project
$ tuist generate
```

## Warnings

Please note that `tuist` allows us to describe the project with a Swift DSL. Any manual change to the project will be *discarded*. As such, you must edit the appropriate `tuist` configuration files.
You can use the following command to edit the manifests:

```bash
$ tuist edit --permanent
```

*Small note: you need to be able to build the core to successfully build the app, for more information, take a look at the `core` folder in the rust folder*
