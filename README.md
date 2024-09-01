# WikiSite

![GitHub license](https://img.shields.io/github/license/WebRodent/wikisite)
![GitHub last commit](https://img.shields.io/github/last-commit/WebRodent/wikisite)
![GitHub issues](https://img.shields.io/github/issues/WebRodent/wikisite)
![GitHub stars](https://img.shields.io/github/stars/WebRodent/wikisite)

WikiSite is an automated system for aggregating and publishing GitHub wikis across your organization. This tool leverages Jekyll with the Just the Docs theme to convert wiki content into a cohesive, user-friendly static site hosted on GitHub Pages.

## Key Features

- **Automated Wiki Aggregation:** Automatically fetches wikis from repositories marked with the `shared-wiki` property.
- **Jekyll Conversion:** Converts wiki markdown to Jekyll-compatible markdown with appropriate front matter.
- **Asset Management:** Downloads and integrates all referenced images into the generated site.
- **Continuous Deployment:** Integrates with GitHub Actions for seamless deployment to GitHub Pages.

## Prerequisites

- **GitHub App:** Requires a GitHub App with read access to repository contents.
- **Shared-Wiki Property:** Repositories must have a custom boolean property `shared-wiki` set to `true`.
- **Image References:** Only image references pointing to repository assets are supported (e.g., `https://github.com/owner/repo/blob/branch/images/example.png`).

## Getting Started

### 1. Use This Repository as a Template

Click the "Use this template" button at the top of this repository to create a new repository based on this template.

### 2. Configure the GitHub App

Ensure you have a GitHub App with the necessary permissions to read repository contents.

### 3. Set Up Repositories

For each repository you want to include, set the custom property `shared-wiki` to `true`.

### 4. Running the Site Locally

To test the Jekyll site locally, follow these steps:

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/yourusername/wikisite.git
    cd wikisite
    ```

2. **Install Dependencies**:
    ```bash
    bundle install
    ```

3. **Pull All Wikis**:
    ```bash
    ./scripts/pull-all-wikis.sh
    ```

4. **Preprocess Wikis**:
    ```bash
    ./scripts/preprocess-wikis.sh
    ```

5. **Pull All Assets**:
    ```bash
    ./scripts/pull-all-wiki-assets.sh
    ```

6. **Replace Asset References**:
    ```bash
    ./scripts/replace-asset-references.sh
    ```

7. **Build the Site**:
    ```bash
    bundle exec jekyll build
    ```

8. **Serve the Site Locally**:
    ```bash
    bundle exec jekyll serve
    ```

   The site will be accessible at `http://localhost:4000`.

### 5. Deploy the Site

Use the provided GitHub Actions workflow to automatically deploy your site to GitHub Pages.

Change the environments in the workflow file to match your org and main wiki repository.

```yaml
env:
  ENV_ORG_NAME: yourorg
  ENV_MAIN_WIKI: main-wiki-repo
```

### 6. Customization

You can customize the look and feel of your site by editing the `_config.yml` and other Jekyll-related settings.

## Contributing

We welcome contributions! Please check out our [contributing guide](CONTRIBUTING.md) for more details.

## License 

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Code of Conduct

Please follow our [Code of Conduct](CODE_OF_CONDUCT.md) in all your interactions with the project.

## Acknowledgements

This project uses the [Just the Docs](https://github.com/just-the-docs/just-the-docs) theme.

## Support

For any issues, please open an issue on this repository.

## Contact

For more information, you can reach out to the project maintainer at [github@webrodent.com](mailto:github@webrodent.com).
