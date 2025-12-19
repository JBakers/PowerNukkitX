# PowerNukkitX Copilot Instructions

## Project Overview

PowerNukkitX is a feature-rich, highly customizable third-party server software for Minecraft: Bedrock Edition, written in Java.

### Key Features
- Custom Item, Block and Entity support
- Vanilla-like Mob AI
- Terra Generator integration
- Full Vanilla Command Support
- Full Item, Block and Container Support

## Technology Stack

- **Language**: Java 21 (OpenJDK/Temurin)
- **Build Tool**: Gradle (Kotlin DSL)
- **Testing**: JUnit 5, JaCoCo for coverage
- **Key Dependencies**:
  - Netty for networking
  - Guava, Fastutil for utilities
  - LevelDB for world storage
  - Terra for world generation
  - Log4j2 for logging
  - Lombok for code generation

## Build & Development

### Local Build
```bash
./gradlew shadowJar
```

### Run Tests
```bash
./gradlew test
```

### Docker Build
```bash
docker build -t powernukkitx:latest .
```

## Code Standards

1. **Java Version**: Target Java 21, use modern Java features
2. **Code Style**: Follow existing conventions, use `.editorconfig`
3. **Testing**: Write JUnit 5 tests for new functionality
4. **Dependencies**: Use version catalog in `gradle/libs.versions.toml`
5. **Lombok**: Use Lombok annotations appropriately (@Getter, @Setter, etc.)

## Important Repository-Specific Requirements

### Maven Repositories
The project uses custom Maven repositories that may require allowlisting:
- `jitpack.io`
- `repo.opencollab.dev`
- `repo.powernukkitx.org`

### JVM Arguments
When running or testing, always include these JVM args:
```
--add-opens java.base/java.lang=ALL-UNNAMED
--add-opens java.base/java.io=ALL-UNNAMED
```

### Dockerfile Considerations
- Multi-stage build: separate build and runtime stages
- Build stage: eclipse-temurin:21-jdk-jammy
- Runtime stage: eclipse-temurin:21-jdk-jammy (JDK needed, not just JRE)
- Git submodules must be initialized before build
- Expose port 19132 (Minecraft Bedrock default)
- Run as non-root user (minecraft:minecraft)

## Project Structure

- `src/main/java/cn/nukkit/` - Core server implementation
- `src/main/resources/` - Configuration files, language files
- `src/test/java/` - Test files
- `gradle/` - Gradle wrapper and version catalog
- `.github/` - GitHub workflows and templates

## Testing Guidelines

- Tests are configured with parallel execution
- Maximum 1GB memory per test JVM
- JaCoCo generates XML reports for coverage
- Test logging shows passed, skipped, and failed tests

## Common Tasks

### Adding a New Feature
1. Create appropriate Java classes in `src/main/java/`
2. Add corresponding tests in `src/test/java/`
3. Update documentation if needed
4. Ensure tests pass with `./gradlew test`

### Adding Dependencies
1. Update `gradle/libs.versions.toml`
2. Reference in `build.gradle.kts` using `libs.` notation
3. Document why the dependency is needed

### Modifying Build Configuration
- All build logic is in `build.gradle.kts`
- Use Kotlin DSL syntax
- Test changes with `./gradlew build --dry-run`

## Repository URLs

When working with external resources, be aware these repositories are used:
- Maven Central: `https://repo.maven.apache.org/maven2/`
- JitPack: `https://jitpack.io`
- PowerNukkitX Repo: `https://repo.powernukkitx.org`
- OpenCollab: `https://repo.opencollab.dev`
