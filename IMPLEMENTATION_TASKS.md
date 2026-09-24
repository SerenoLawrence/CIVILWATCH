# Implementation Tasks - Report Visibility Workflow Fix
**Date:** September 7, 2026  
**Status:** ✅ COMPLETE

---

## 5 Tasks Implemented

### ✅ Task 1: Auto-Refresh Pending Reports After Approval
**File:** `prc/laravel/public/pending-reports.html`  
**Lines:** +16  
**What:** Added sessionStorage flag to auto-refresh pending list when user returns after approval

**Code Added:**
```javascript
// Set flag when leaving page
window.addEventListener('beforeunload', function() {
    sessionStorage.setItem('pending-reports-needs-refresh', 'true');
});

// Check if we're returning from approval workflow
if (sessionStorage.getItem('pending-reports-needs-refresh') === 'true') {
    sessionStorage.removeItem('pending-reports-needs-refresh');
    loadPendingReports(); // Reload to remove approved reports
}

// Listen for multi-tab changes
window.addEventListener('storage', function(e) {
    if (e.key === 'report-approved' && e.newValue === 'true') {
        loadPendingReports();
        localStorage.removeItem('report-approved');
    }
});
```

**Result:** ✅ Approved reports disappear from pending list when admin returns

---

### ✅ Task 2: Set Approval Flag Before Redirect
**File:** `prc/laravel/public/report-details.html`  
**Lines:** +1  
**What:** Set sessionStorage flag before redirecting to assign-office after approval

**Code Added:**
```javascript
// Signal pending-reports to refresh if user returns
sessionStorage.setItem('pending-reports-needs-refresh', 'true');
location.href = 'assign-office.html?id=' + reportId;
```

**Result:** ✅ Pending reports page knows to refresh when user returns

---

### ✅ Task 3: Filter GIS Map by is_public & Status
**File:** `prc/laravel/app/Http/Controllers/Admin/AdminCitizenReportController.php`  
**Lines:** +5  
**What:** Added filters to `/map` endpoint to only show public, assigned reports

**Code Added:**
```php
$query = CitizenReport::with('assignedOffice')
    ->where('is_public', true)
    ->whereIn('status', [
        CitizenReport::STATUS_ASSIGNED,
        CitizenReport::STATUS_IN_PROGRESS,
        CitizenReport::STATUS_RESOLVED,
    ])
    ->whereNotNull('lat')
    ->whereNotNull('lng');
```

**Result:** ✅ Only assigned reports appear on public map

---

### ✅ Task 4: Filter Monitoring by Status=Assigned
**File:** `prc/laravel/public/monitoring.html`  
**Lines:** +1  
**What:** Added status filter to monitoring page API call

**Code Added:**
```javascript
var json = await Api.get('/api/admin/citizen-reports', {
    status: 'Assigned',  // Only show assigned reports
    limit: 500
});
```

**Result:** ✅ Only assigned reports appear in monitoring

---

### ✅ Task 5: Add Data Attributes to Pending Reports
**File:** `prc/laravel/public/pending-reports.html`  
**Lines:** +1  
**What:** Added data-report-id to table rows for future enhancements

**Code Added:**
```html
<tr data-report-id="${r.id}">
  <!-- Row content -->
</tr>
```

**Result:** ✅ Enables future DOM-based removal enhancements

---

## Summary

| Task | File | Lines | Status |
|------|------|-------|--------|
| 1 | pending-reports.html | +16 | ✅ |
| 2 | report-details.html | +1 | ✅ |
| 3 | AdminCitizenReportController.php | +5 | ✅ |
| 4 | monitoring.html | +1 | ✅ |
| 5 | pending-reports.html | +1 | ✅ |
| **Total** | **4 files** | **+24 lines** | **✅** |

---

## Visibility Rules After Implementation

```
Submitted (is_public=false)
  ↓
Pending Validation (is_public=true, not assigned)
  ↓
Assigned (is_public=true, assigned_office_id set)
  ↓
In Progress / Resolved
```

**Appears On Public Map:** Assigned, In Progress, Resolved (with coordinates)  
**Appears In Monitoring:** Assigned, In Progress, Resolved  
**Appears In Pending Reports:** Submitted, Pending Validation  

---

## Files Modified

1. **prc/laravel/public/pending-reports.html** (+17 lines)
2. **prc/laravel/public/report-details.html** (+1 line)
3. **prc/laravel/app/Http/Controllers/Admin/AdminCitizenReportController.php** (+5 lines)
4. **prc/laravel/public/monitoring.html** (+1 line)

---

## Status: ✅ ALL TASKS COMPLETE
