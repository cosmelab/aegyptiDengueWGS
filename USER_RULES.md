# User Rules for AI Assistant Interactions

## 🎯 **Core Principle: Transparency First**

**I must always list ALL changes made to achieve any goal or fix any problem.**

## 📋 **Required Actions for Every Change:**

### 1. **Before Making Changes:**

- ✅ **Ask permission** before creating new files/scripts
- ✅ **Explain what I'm going to change** and why
- ✅ **List all files that will be modified**
- ✅ **Confirm the user wants these changes**

### 2. **When Making Changes:**

- ✅ **List every single file modified**
- ✅ **Show exact changes made** (file names, line numbers, content)
- ✅ **Explain the purpose of each change**
- ✅ **Note any dependencies or side effects**

### 3. **After Making Changes:**

- ✅ **Provide a complete summary** of all modifications
- ✅ **List any new files created**
- ✅ **Note any files deleted or renamed**
- ✅ **Warn about potential impacts** on other scripts/files

## 🚫 **Strict Prohibitions:**

### **Never Change Without Permission:**

- ❌ **Variable names** that other scripts depend on
- ❌ **File names** that are referenced elsewhere
- ❌ **Function names** that are called by other code
- ❌ **Configuration values** without explicit approval
- ❌ **Project structure** without detailed explanation

### **Never Create Without Asking:**

- ❌ **New scripts** unless explicitly requested
- ❌ **New configuration files** without permission
- ❌ **New directories** without approval
- ❌ **Backup files** without notification

## ✅ **Required Communication Format:**

### **Before Changes:**

```
🎯 GOAL: [What we're trying to achieve]
📁 FILES TO MODIFY: [List all files]
🔧 CHANGES NEEDED: [Detailed explanation]
❓ CONFIRMATION: Do you want me to proceed?
```

### **After Changes:**

```
✅ COMPLETED: [What was accomplished]
📝 FILES MODIFIED:
  - file1.py: [specific changes]
  - file2.sh: [specific changes]
📄 NEW FILES:
  - newfile.py: [purpose]
🗑️ DELETED FILES:
  - oldfile.py: [reason]
⚠️ IMPACTS: [Any potential side effects]

🎯 OBJECTIVE: [Describe the original objective, how it was achieved, what changes were made, and how the problem was solved]
```

**Example:**

```
🎯 OBJECTIVE: Give my agent clear rules to avoid Cursor's terminal-response hang; I met it with five direct, active-voice directives tied to the bug's causes and work-arounds.
```

## 🔍 **Verification Requirements:**

### **Before Proceeding:**

- ✅ **Check for dependencies** on any files I want to change
- ✅ **Search for references** to variable/function names
- ✅ **Verify file paths** are correct
- ✅ **Confirm no conflicts** with existing code

### **After Changes:**

- ✅ **Verify changes work** as intended
- ✅ **Check no breaking changes** to existing functionality
- ✅ **Confirm all dependencies** are still satisfied

## 💻 **Terminal Command Execution Rules:**

### **Cursor Terminal Response Fix:**

**Problem:** Cursor's wrapper times out when it sees no output, causing commands to hang and requiring manual intervention.

**Solution:** Use these rules to guarantee output or immediate backgrounding:

### **1. Always Use Background Execution:**

- ✅ **Set `is_background: true`** for ALL terminal commands
- ✅ **Only use foreground** if user explicitly says "run foreground"
- ✅ **Assume every command may exit before I notice**

### **2. Add Completion Sentinel:**

- ✅ **Append `&& echo __CURSOR_DONE__`** to all one-liner commands
- ✅ **End scripts with `echo __CURSOR_DONE__`** for multi-line scripts
- ✅ **Stop polling as soon as the sentinel prints**

### **3. Pre-sanitize Interactive Commands:**

- ✅ **Add non-interactive flags** to avoid prompts:
  - `--yes`, `--quiet`, `--no-verify`, `--no-optional-locks`
  - `-y` for package managers
  - `--force` when safe to do so

### **4. Batch Related Commands:**

- ✅ **Generate temporary shell scripts** for multiple related commands
- ✅ **Execute script once** and monitor overall exit status
- ✅ **Don't run steps individually** when they're related

### **5. Fallback Plan:**

- ✅ **If command stalls after 8s** of idle output, notify user
- ✅ **Suggest either** (a) manual run or (b) killing the job ID
- ✅ **Don't wait indefinitely** for command completion

### **Example Implementation:**

```bash
# Good - Background with sentinel
python3 -c "print(1+1)" && echo __CURSOR_DONE__

# Good - Non-interactive flags
git push --quiet && echo __CURSOR_DONE__

# Good - Batched commands
echo "#!/bin/bash
command1
command2
echo __CURSOR_DONE__" > temp_script.sh && bash temp_script.sh
```

## 📚 **Special Rules for This Project:**

### **RNA-seq Analysis Project:**

- ✅ **Preserve data paths** in scripts
- ✅ **Maintain sample naming conventions**
- ✅ **Keep Docker configuration** intact
- ✅ **Respect existing file structure**
- ✅ **Maintain compatibility** with HPC systems

### **Package Management:**

- ✅ **List all packages** being added/removed
- ✅ **Explain why** each change is needed
- ✅ **Verify multi-architecture compatibility**
- ✅ **Check for conflicts** with existing packages

## 🎯 **Example Compliance:**

### **Good Response:**

```
🎯 GOAL: Fix package compatibility issue
📁 FILES TO MODIFY:
  - Dockerfile (lines 45-50)
  - check_conda_packages.sh (lines 15-20)
🔧 CHANGES NEEDED: Remove unused packages and update package list
❓ CONFIRMATION: Proceed with these changes?

[After changes]
✅ COMPLETED: Fixed package compatibility
📝 FILES MODIFIED:
  - Dockerfile: Removed graphviz, pygraphviz (lines 47-48)
  - check_conda_packages.sh: Updated package list (lines 15-20)
⚠️ IMPACTS: No breaking changes, all dependencies preserved

🎯 OBJECTIVE: Fix package compatibility issue in Docker environment; I met it by removing unused packages (graphviz, pygraphviz) and updating the package verification script to match the actual Dockerfile contents.
```

### **Bad Response:**

```
Fixed the issue.
[No details about what was changed]
```

## 🔄 **Update Process:**

- ✅ **This document can be updated** as we discover new requirements
- ✅ **Rules are binding** for all future interactions
- ✅ **User can modify rules** at any time
- ✅ **Changes to rules** must be documented here

---

**Last Updated:** [Current Date]
**Project:** DiapauseRNASeq Analysis
**Purpose:** Ensure transparent, safe, and predictable AI assistance
