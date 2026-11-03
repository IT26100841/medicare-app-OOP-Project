# Real GitHub contribution evidence

The uploaded .git directory had no HEAD commit. Staged files are not commits.
It is impossible to reconstruct real member contributions from that snapshot.
This archive excludes that unborn metadata and does not fabricate a history.
If your real GitHub repository already has history, copy these changes into a
branch of that repository instead of creating a replacement repository.

Each member should use their own Git identity and commit actual work:

```bash
git clone YOUR_REAL_REPOSITORY_URL
cd YOUR_REPOSITORY
# Copy the corrected files into this working tree, keeping the real .git folder.
git switch -c fix/medicare-review
# Inspect all changes and divide subsequent work honestly.
git status
git diff
# Stage only the files you actually worked on/reviewed.
git add PATH_TO_YOUR_FILES
git commit -m "Describe the actual change you implemented"
git push -u origin fix/medicare-review
```

For a genuinely new repository, use git init and create an honest initial import
commit. An imported baseline is not evidence that one member wrote all its code.
Do not backdate commits or attribute repair work to other people.

Before final submission, collect actual evidence:

```bash
git log --all --date=short --pretty=format:"%h %ad %an %s" > commit-history.txt
git shortlog -sne --all > contributors.txt
```

Insert the real repository URL, member/module table and commit evidence into the
final report. The team must understand and explain the backend changes in viva.
