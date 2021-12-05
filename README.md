## A practice of using TDD to implementing infinite scrolling

There are four schemes:

GitHubAPIApp: The scheme to run the app and unit tests of the UI part of the app.

GitHubAPI: The scheme to run the unit tests of the UI independent part.

GitHubAPISnapshotTests: The scheme to run slower snapshot tests.

GitHubAPIUIAcceptanceTests: The scheme to run the slowest UI tests.

### Architecture Overview
![architecture overview](https://github.com/ctwdtw/GitHubAPIPractice/blob/504a3c4cb112decf2b7a059d24e9ffc976d3e935/class-diagram.png)
