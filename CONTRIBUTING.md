# Contributing to Student Transportation App

First off, thank you for considering contributing to the Student Transportation App! It's people like you that make this project such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the issue list as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* Use a clear and descriptive title
* Describe the exact steps which reproduce the problem
* Provide specific examples to demonstrate the steps
* Describe the behavior you observed after following the steps
* Explain which behavior you expected to see instead and why
* Include screenshots if possible
* Include your environment details (OS, Flutter version, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* Use a clear and descriptive title
* Provide a step-by-step description of the suggested enhancement
* Provide specific examples to demonstrate the steps
* Describe the current behavior and explain which behavior you expected to see instead
* Explain why this enhancement would be useful
* List some other applications where this enhancement exists, if applicable

### Pull Requests

* Fill in the required template
* Do not include issue numbers in the PR title
* Include screenshots and animated GIFs in your pull request whenever possible
* Follow the Flutter style guide
* Include thoughtfully-worded, well-structured tests
* Document new code
* End all files with a newline

## Style Guide

### Dart Style Guide

* Follow the [Effective Dart: Style Guide](https://dart.dev/guides/language/effective-dart/style)
* Use `flutter format .` before committing
* Run `flutter analyze` and fix any issues before committing

### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line

### Documentation Style Guide

* Use [Markdown](https://daringfireball.net/projects/markdown)
* Reference functions and classes in backticks: \`MyClass\`

## Project Structure

Please maintain the existing project structure:

```
lib/
├── config/             # App configuration and constants
├── models/            # Data models
├── providers/         # State management
├── routes/           # Navigation and routing
├── services/         # Business logic and API services
├── utils/            # Utility functions and helpers
├── views/            # UI screens
├── widgets/          # Reusable widgets
└── main.dart         # App entry point
```

## Development Process

1. Fork the repo
2. Create a new branch from `main`
3. Make your changes
4. Run tests
5. Update documentation
6. Create PR

### Setting Up Development Environment

1. Install Flutter (3.0.0 or higher)
2. Clone your fork
3. Install dependencies
4. Configure Firebase
5. Set up Google Maps API

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/my_test.dart

# Run with coverage
flutter test --coverage
```

## Community

* Join our [Discord server](https://discord.gg/your-server)
* Follow us on [Twitter](https://twitter.com/your-handle)
* Read our [Blog](https://your-blog.com)

## Questions?

Feel free to contact the project maintainers if you have any questions.

## Code Review Process

### Before Submitting for Review
1. Self-review your changes
2. Update tests and documentation
3. Run the full test suite
4. Format your code
5. Verify CI/CD pipeline passes

### Review Guidelines
- Keep changes focused and atomic
- Include relevant tests
- Update documentation
- Follow existing patterns
- Consider performance implications

### Review Checklist
- [ ] Code follows style guide
- [ ] Tests are passing
- [ ] Documentation is updated
- [ ] Commit messages are clear
- [ ] No unnecessary changes
- [ ] Performance impact considered

## Testing Guidelines

### Unit Tests
- Test individual components
- Mock dependencies
- Cover edge cases
- Maintain test isolation

### Widget Tests
```dart
testWidgets('MyWidget displays correct text', (WidgetTester tester) async {
  await tester.pumpWidget(MyWidget());
  expect(find.text('Expected Text'), findsOneWidget);
});
```

### Integration Tests
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete flow test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    // Test steps...
  });
}
```

### Performance Tests
- Measure render times
- Check memory usage
- Profile CPU usage
- Test network efficiency

## Release Process

### Version Numbering
- Follow Semantic Versioning
- Document breaking changes
- Update changelog
- Tag releases

### Pre-release Checklist
1. Update version numbers
2. Run full test suite
3. Update documentation
4. Create release notes
5. Verify builds
6. Test migrations

### Release Steps
1. Merge to release branch
2. Create release tag
3. Generate builds
4. Update store listings
5. Deploy to production
6. Monitor rollout

## Development Setup

### Required Tools
- Flutter SDK (3.0.0+)
- Android Studio / VS Code
- Git
- Firebase CLI
- Google Cloud SDK

### Environment Setup
```bash
# Clone repository
git clone https://github.com/yourusername/student_transportation_app.git

# Install dependencies
flutter pub get

# Setup pre-commit hooks
./scripts/setup-hooks.sh

# Configure environment
cp .env.example .env
```

### IDE Setup
- Install Flutter plugin
- Configure formatting
- Set up linting
- Configure hot reload

## Branch Strategy

### Branch Types
- `main`: Production code
- `develop`: Development code
- `feature/*`: New features
- `bugfix/*`: Bug fixes
- `hotfix/*`: Urgent fixes
- `release/*`: Release preparation

### Branch Naming
- Use descriptive names
- Include issue number
- Use lowercase
- Use hyphens for spaces

Example: `feature/user-authentication-#123`

## Writing Good Commit Messages

### Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- feat: New feature
- fix: Bug fix
- docs: Documentation
- style: Formatting
- refactor: Code restructuring
- test: Adding tests
- chore: Maintenance

### Examples
```
feat(auth): implement biometric login

Add fingerprint and face ID authentication options.
Includes unit tests and documentation updates.

Closes #123
```

## Code Style Examples

### Dart
```dart
// Good
class UserRepository {
  Future<User> getUser(String id) async {
    try {
      final response = await _api.getUser(id);
      return User.fromJson(response);
    } catch (e) {
      throw UserNotFoundException();
    }
  }
}

// Bad
class userRepo {
  getuser(id) async {
    var resp = await api.getUser(id);
    return User.fromJson(resp);
  }
}
```

### Widget Structure
```dart
class CustomWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const CustomWidget({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(title),
    );
  }
}
```

## Documentation Guidelines

### Code Documentation
- Document public APIs
- Explain complex logic
- Include examples
- Reference related code

### Example
```dart
/// Fetches user data from the remote API.
///
/// Parameters:
/// - [userId]: The unique identifier of the user
///
/// Returns a [User] object if found, throws [UserNotFoundException] otherwise.
///
/// Example:
/// ```dart
/// final user = await getUserData('123');
/// print(user.name);
/// ```
Future<User> getUserData(String userId) async {
  // Implementation
}
```

## Getting Help

### Resources
- Official Flutter documentation
- Project wiki
- Stack Overflow
- Discord community

### Contact
- Technical questions: Stack Overflow
- Bug reports: GitHub Issues
- Feature requests: GitHub Discussions
- Security issues: security@example.com

Remember: We're here to help! Don't hesitate to ask questions. 