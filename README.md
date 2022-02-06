# vexl

## Getting started

- Clone this repo
- Run `pod install` (make sure you are using CocoaPods 1.8.0 and higher)
- Open `vexl.xcworkspace`

## API Documentation

- **URL:** FIXME

## Development

- We use MVVM-C architecture based on RxSwift.
- For every Scene in the app create new folder under `Scenes` with at least `ViewController`, `ViewModel` and `Coordinator`.
- Small generic views should be placed in `View` folder. Try to structure these views into groups when possible.
- Every Coordinator has return value, which is Observable. **Make sure you always return something when closing the scene, because of memory leaks.**
- In Debug enviroment is log with current RxSwift resources. Use this for checking any memory leaks. When you open the scene and close it properly, resources should go down to previous value.
- **Whenever you create a closure make sure, there can't be retain cycle.** Use `[weak self]` or `[unowned self]` when you are sure `self` can never be nil.
- **Localize every single string in project!**
- **Place all constants in `Constants` struct!**
- **App appearance should be always in `Appearance` struct!**
- Try to keep the project as simple as possible! When you have a small viewController, don't create viewModels, coordinator etc.

## GIT flow

- There are two main branches: `master` and `devel`.
- Never push to `master` branch!
- `master` branch contains released version to AppStore and should have tag with version number.
- `devel` is used for our development.
- Create new branch for every task. Only hot fixes should be pushed to `devel` branch.
- When you need to merge your branch do `devel`, create merge request and assign someone to check it before merge.
- Also make a rebase from current `devel` branch and resolve all conflicts before merging.


## Deployment

- In project are 4 configurations:
- `Debug` -  for local development
- `Devel` - for Firebase App Distribution releases (testing)
- `AppStore` - for final release to AppStore.
- Every configuration has it's own schema to simplify builds.
- Production key is stored at our google drive.

## Continuous integration

* This project has configured CI and CD using Gitlab CI and Fastlane
* Stage `Lint` - runs Swiftlint and creates a report
* Stage `Test` - build the app and runs tests
* Stage `Deploy` - automated deploy to HockeyApp and AppStoreConnect

- Stage `Lint` and `Test` runs with every push to any branch
- When you push (merge) to `devel` branch, new build will be automatically send to Firebase. CI increases the build number, creates an appropriate tag and pushes changes to git.
- From any branch except `master` and `devel` you can deploy Firebase build manually.
- When you push (merge) to `master` branch, you can deploy production AppStore build manually.

* If your commit message contains `[ci skip]` or `[skip ci]`, using any capitalization, the commit will be created but the pipeline will be skipped.

## Used tools

### R.Swift

We use R.Swift for strong typing images, localized strings, etc.

- Documentation: https://github.com/mac-cain13/R.swift
- For localized strings use `tr(L.stringKey)`, with variables `tr(L.stringKeyWithVariables, parameters: ["variableName": value])`

### SwiftLint

A tool to enforce Swift style and conventions.

- SwiftLint rules: https://github.com/realm/SwiftLint/blob/master/Rules.md
- Always treat warnings as errors!

### UIViewStyle

Struct for styling UI elements (UIButton, UILabel, etc.). These styles can be reused for multiple elements and also defined as global Styles in `Appearance` struct.

- https://medium.cobeisfresh.com/composable-type-safe-uiview-styling-with-swift-functions-8be417da947f#.fagjztheu
- Usage example:

```
static let titleLabel = UIViewStyle<UILabel> {
    $0.font = Appearance.font(ofSize: 24, weight: .bold)
    $0.textAlignment = .center
    $0.textColor = Appearance.Colors.title
    $0.numberOfLines = 1
}
```

### SnapKit

A Swift Autolayout DSL for iOS

- Documentation: https://github.com/SnapKit/SnapKit
