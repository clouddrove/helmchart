## 🚀 Changes
<!-- Describe what this PR does -->

---

## 📦 Helm Chart Impact
- [ ] This PR does NOT affect any Helm chart
- [ ] This PR updates an existing Helm chart
- [ ] This PR adds a new Helm chart

If Helm chart is affected, mention chart name(s):


---

## 🔖 Version Update Checklist (MANDATORY if chart is modified)

- [ ] Updated `version` in `Chart.yaml`
- [ ] Updated `appVersion` in `Chart.yaml` (if app changes)
> ⚠️ PRs modifying Helm charts without version updates should NOT be merged.
> ### 📌 Versioning Guide (`X.Y.Z`)
> Follow semantic versioning for `version` in `Chart.yaml`:
> - **X (MAJOR)** → Breaking changes  
>   - Incompatible values.yaml changes  
>   - Resource renaming/removal  
>   - Anything requiring manual intervention during upgrade  
> 
> - **Y (MINOR)** → Backward-compatible feature changes  
>   - New templates/resources added  
>   - New optional values  
>   - Feature enhancements  
> 
> - **Z (PATCH)** → Backward-compatible fixes  
>   - Bug fixes  
>   - Template corrections  
>   - Small internal changes (no behavior change)

---

## 🧪 Validation
- [ ] `helm lint` passed
- [ ] Chart tested locally (install/upgrade)

---

## 📝 Notes (if any)
<!-- Anything reviewers should know -->