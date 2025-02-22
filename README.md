### 🚀 **Git Submodules Cheat Sheet**  

#### **Basic Workflow for Working with Submodules**  

### ✅ **1. Cloning the Main Repository with Submodules**  
When cloning a repo with submodules, always use:  
```bash
git clone --recurse-submodules https://github.com/nkamkolkar/SwiftMediaService.git
```
If you already cloned without `--recurse-submodules`, initialize them manually:  
```bash
git submodule update --init --recursive
```

---

### 🔄 **2. Pulling Latest Changes (Including Submodules)**  
```bash
git pull --recurse-submodules
git submodule update --recursive --remote
```
- Ensures you get the latest changes from both the main repo and submodules.

---

### 🌿 **3. Working with Submodules (Switching Branches, Committing, Pushing)**  

#### **a. Navigating to a Submodule**
```bash
cd MediaVaultClients/MediaVaultClient   # Navigate to the submodule directory
git checkout main                       # Switch to the desired branch
```

#### **b. Making Changes in a Submodule**
1. Edit files in the submodule.
2. Stage and commit inside the submodule:
   ```bash
   git add .
   git commit -m "Updated MediaVaultClient with new features"
   git push origin main  # Push changes to the submodule's repository
   ```
3. Go back to the main repo and **update the submodule reference**:
   ```bash
   cd ../..  # Back to the main repo
   git add MediaVaultClients/MediaVaultClient
   git commit -m "Updated submodule reference for MediaVaultClient"
   git push origin main
   ```
   This ensures the main repo tracks the latest version of the submodule.

---

### 🔀 **4. Switching Branches in the Main Repo & Submodules**  
If switching branches in the main repo:
```bash
git checkout feature-branch
git submodule update --recursive --remote  # Ensures submodules are on the right commit
```

For submodules, checkout the right branch **inside the submodule**:
```bash
cd MediaVaultClients/MediaVaultClient
git checkout feature-branch
```

---

### ❌ **5. Removing a Submodule (If Needed)**
```bash
git submodule deinit -f MediaVaultClients/MediaVaultClient
rm -rf .git/modules/MediaVaultClients/MediaVaultClient
git rm -f MediaVaultClients/MediaVaultClient
```
This removes it from Git but not from the filesystem.

---

### 💡 **6. Summary of Key Commands**
| **Action**                      | **Command** |
|----------------------------------|------------|
| Clone repo with submodules       | `git clone --recurse-submodules <repo>` |
| Pull latest updates (with submodules) | `git pull --recurse-submodules` |
| Update all submodules            | `git submodule update --recursive --remote` |
| Add a new submodule              | `git submodule add <repo_url> <path>` |
| Remove a submodule               | `git submodule deinit -f <path>` + `git rm -f <path>` |
| Commit & push submodule changes  | `cd <submodule>` → `git commit -m "message"` → `git push origin <branch>` |
| Update submodule reference in main repo | `git add <submodule>` → `git commit -m "Update submodule"` → `git push origin main` |
