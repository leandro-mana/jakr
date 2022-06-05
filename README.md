---
noteId: "f856aee0e48011ec8831318263c77b0e"
tags: []

---

## JAKR - Just Another Keyword Releaser

GitHub Action to Create `main|master` releases based on a keyword

### **Intro**
Though it would be simpler to set up a variable word to be specified to make a release, the purpose of this action is to explicitly create a main branch release when the `RELEASE-` keyword is specified in the `head_commit` message, by getting the version like, `RELEASE-1.0.0` -> `1.0.0` and from there to create such release and tag in `main`. If a different work needs to be specified, then modify the `KEYWORD` variable in the [Makefile](Makefile).

### **Secrets**
As the example shown bellow, to use this GitHub Action into a workflow, the `API_TOKEN` secret needs to be added, it's a [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with admin rights on the repo, and then stored as an [encrypted secret](https://docs.github.com/en/actions/security-guides/encrypted-secrets) this access is used to create the release via the [API](https://docs.github.com/en/rest/releases/releases#create-a-release)


In the example bellow, there is a condition to check if running in `main` otherwise skip the step, the recommendation is either via [git squash](https://www.atlassian.com/git/tutorials/rewriting-history/git-rebase) or just when merging addind the `RELEASE-version` as last message, using [semantic versioning](https://semver.org/).

```yml
name: JAKR - keyword-releaser

on: [push]

jobs:
  build: 
    runs-on: ubuntu-latest
    steps:
    - name: Checkout Code
      uses: actions/checkout@v2

    - name: Create a Release based on Keyword
      if: ${{ github.ref == 'refs/heads/main' }}
      uses: leandro-mana/jakr@main
      env:
        API_TOKEN: ${{ secrets.API_TOKEN }}
```

### **Make Targets**
`make [help]`

#### References
- [GitHub Docs](https://docs.github.com/en)
- Linked Learning [Learning GitHub Actions](https://www.linkedin.com/learning/learning-github-actions-2/automating-with-github-actions-2?autoplay=true)