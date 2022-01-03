## A practice of using TDD to implementing infinite scrolling

There are four schemes:

GitHubAPIApp: The scheme to run the app and unit tests of the UI part of the app.

GitHubAPI: The scheme to run the unit tests of the UI independent part.

GitHubAPISnapshotTests: The scheme to run slower snapshot tests.

GitHubAPIUIAcceptanceTests: The scheme to run the slowest UI tests.

### Architecture Overview

1. MVVM with adapter pattern
![architecture overview](https://github.com/ctwdtw/GitHubAPIPractice/blob/develop/mvvm-class-diagram.png)

2. Navigation, view controllers are decoupled. This can be viewd as a simplified coordinator pattern.
![navigation architecture overview](https://github.com/ctwdtw/GitHubAPIPractice/blob/develop/navigation-class-diagram.png)
