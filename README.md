## A practice of using TDD to implementing infinite scrolling

There are four schemes:

GitHubAPIApp: The scheme to run the app and unit tests of the UI part of the app.

GitHubAPI: The scheme to run the unit tests of the UI independent part.

GitHubAPISnapshotTests: The scheme to run slower snapshot tests.

GitHubAPIUIAcceptanceTests: The scheme to run the slowest UI tests.

### Architecture Overview

1. MVVM with adapter pattern
![architecture overview](https://github.com/ctwdtw/GitHubAPIPractice/blob/504a3c4cb112decf2b7a059d24e9ffc976d3e935/class-diagram.png)

2. Navigation, a simplified coordinator pattern
<img width="945" alt="navigation-class-diagram" src="https://user-images.githubusercontent.com/7893446/144791400-ca483932-b6cf-4e7c-a240-da6cb716e9d4.png">
