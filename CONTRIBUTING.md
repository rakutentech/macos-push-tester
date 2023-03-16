# Contributing

## Found a bug or have a suggestion?
If you find a bug in the source code or you have a suggestion for an improvement or new feature, please submit an issue to discuss with the team before working on your PR.

## Submit an Issue
Please fill the following information in each (bug) issue you submit:
  
* Title: Use a clear and descriptive title for the issue to identify the problem
* Description: Description of the issue
* Steps to Reproduce: numbered step by step. (1,2,3.… and so on)
* Expected behaviour: What you expect to happen
* Actual behaviour: What actually happens
* Version: The version of the library
* Repository: Link to the repository you are working with
* Operating system: The operating system used
* Additional information: Any additional to help to reproduce. (screenshots, animated gifs)
  
## Pull Requests
1. Fork the [repo](https://github.com/rakutentech/macos-push-tester.git)
2. Create a branch and implement your feature/bugfix & add test cases
3. Ensure test cases & static analysis runs succesfully
4. Submit a pull request to `master` branch
  
Please include unit tests where necessary to cover any functionality that is introduced.
  
## Coding Guidelines
* All features or bug fixes **must be tested** by one or more unit tests/specs
* All public API methods (APNS, FCM, PusherMainView) **must be documented** in a standard format and potentially in the user guide
* All code must follow the style of the existing code
