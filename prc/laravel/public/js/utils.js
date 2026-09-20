// ============================================================
// CIVILWATCH Admin Dashboard — Utilities
// ============================================================

const Utils = {

    // Format date string
    formatDate(dateStr) {
        return dateStr || '—';
    },

    // Get status badge HTML
    statusBadge(status) {
        const map = {
            'Pending Validation': {
                cls: 'badge-validation',
                icon: 'schedule',
                label: 'Pending Validation'
            },
            'Assigned': {
                cls: 'badge-assigned',
                icon: 'assignment_ind',
                label: 'Assigned'
            },
            'In Progress': {
                cls: 'badge-inprogress',
                icon: 'autorenew',
                label: 'In Progress'
            },
            'Resolved': {
                cls: 'badge-resolved',
                icon: 'check_circle',
                label: 'Resolved'
            },
        };
        const s = map[status] || {
            cls: 'badge-pending',
            icon: 'help',
            label: status
        };
        return `<span class="badge ${s.cls}"><span class="material-symbols-outlined">${s.icon}</span>${s.label}</span>`;
    },

    // Get category badge HTML
    categoryBadge(category) {
        if (category === 'Infrastructure') {
            return `<span class="badge-infra"><span class="material-symbols-outlined">construction</span>Infrastructure</span>`;
        }
        return `<span class="badge-env"><span class="material-symbols-outlined">eco</span>Environmental</span>`;
    },

    // Placeholder image for broken/missing photos
    photoPlaceholder() {
        return `<div class="table-photo-placeholder"><span class="material-symbols-outlined">image</span></div>`;
    },

    // Show toast notification
    showToast(message, type = 'info', duration = 3000) {
        let container = document.querySelector('.toast-container');
        if (!container) {
            container = document.createElement('div');
            container.className = 'toast-container';
            document.body.appendChild(container);
        }
        const icons = {
            success: 'check_circle',
            error: 'error',
            info: 'info'
        };
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        toast.innerHTML = `<span class="material-symbols-outlined" style="font-size:18px">${icons[type] || 'info'}</span>${message}`;
        container.appendChild(toast);
        setTimeout(() => {
            toast.style.animation = 'none';
            toast.style.opacity = '0';
            toast.style.transition = 'opacity 0.3s ease';
            setTimeout(() => toast.remove(), 300);
        }, duration);
    },

    // Debounce
    debounce(fn, delay = 300) {
        let t;
        return (...args) => {
            clearTimeout(t);
            t = setTimeout(() => fn(...args), delay);
        };
    },

    // Get URL param
    getParam(name) {
        return new URLSearchParams(window.location.search).get(name);
    },

    // Format relative time
    relativeTime(minutesAgo) {
        if (minutesAgo < 1) return 'just now';
        if (minutesAgo < 60) return `${minutesAgo} minutes ago`;
        if (minutesAgo < 120) return '1 hour ago';
        if (minutesAgo < 1440) return `${Math.floor(minutesAgo / 60)} hours ago`;
        return `${Math.floor(minutesAgo / 1440)} days ago`;
    },

    // Highlight search term
    highlight(text, query) {
        if (!query) return text;
        const re = new RegExp(`(${query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi');
        return text.replace(re, '<mark style="background:#FEF9C3;border-radius:2px">$1</mark>');
    }
};

// ============================================================
// Shared Photo renderer - Real Unsplash images for demo
// ============================================================
const PHOTO_URLS = {
    'damaged-road': 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=400&h=300&fit=crop&q=80',
    'illegal-dumping': 'https://images.unsplash.com/photo-1621451537084-482c73073a0f?w=400&h=300&fit=crop&q=80',
    'damaged-sidewalk': 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=400&h=300&fit=crop&q=80',
    'blocked-drainage': 'https://images.unsplash.com/photo-1590845947670-c009801ffa74?w=400&h=300&fit=crop&q=80',
    'overgrown': 'https://images.unsplash.com/photo-1588392382834-a891154bca4d?w=400&h=300&fit=crop&q=80',
    'streetlight': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400&h=300&fit=crop&q=80',
    'broken-bridge': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop&q=80',
    'soil-erosion': 'https://images.unsplash.com/photo-1611273426858-450d8e3c9fce?w=400&h=300&fit=crop&q=80',
    'road-sign': 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400&h=300&fit=crop&q=80',
};

function getPhotoUrl(issue) {
    const key = (issue || '').toLowerCase().replace(/\s+/g, '-');
    const map = {
        'damaged-road': PHOTO_URLS['damaged-road'],
        'illegal-dumping': PHOTO_URLS['illegal-dumping'],
        'damaged-sidewalk': PHOTO_URLS['damaged-sidewalk'],
        'blocked-drainage': PHOTO_URLS['blocked-drainage'],
        'overgrown-vegetation': PHOTO_URLS['overgrown'],
        'broken-streetlight': PHOTO_URLS['streetlight'],
        'soil-erosion': PHOTO_URLS['soil-erosion'],
        'blocked-canal': PHOTO_URLS['blocked-drainage'],
        'road-sign-damage': PHOTO_URLS['road-sign'],
        'damaged-bridge': PHOTO_URLS['broken-bridge'],
    };
    return map[key] || PHOTO_URLS['damaged-road'];
}

// Full-size version for detail pages (larger images)
function getPhotoUrlLarge(issue) {
    const key = (issue || '').toLowerCase().replace(/\s+/g, '-');
    const map = {
        'damaged-road': 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=800&h=500&fit=crop&q=85',
        'illegal-dumping': 'https://images.unsplash.com/photo-1621451537084-482c73073a0f?w=800&h=500&fit=crop&q=85',
        'damaged-sidewalk': 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=800&h=500&fit=crop&q=85',
        'blocked-drainage': 'https://images.unsplash.com/photo-1590845947670-c009801ffa74?w=800&h=500&fit=crop&q=85',
        'overgrown-vegetation': 'https://images.unsplash.com/photo-1588392382834-a891154bca4d?w=800&h=500&fit=crop&q=85',
        'broken-streetlight': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&h=500&fit=crop&q=85',
        'soil-erosion': 'https://images.unsplash.com/photo-1611273426858-450d8e3c9fce?w=800&h=500&fit=crop&q=85',
        'blocked-canal': 'https://images.unsplash.com/photo-1590845947670-c009801ffa74?w=800&h=500&fit=crop&q=85',
        'road-sign-damage': 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800&h=500&fit=crop&q=85',
        'damaged-bridge': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=500&fit=crop&q=85',
    };
    return map[key] || 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=800&h=500&fit=crop&q=85';
}


// ============================================================
// CwModal — Loading / Success / Error modal system
// ============================================================
//
// Usage:
//   CwModal.loading('Saving changes...')   — show non-dismissible spinner
//   CwModal.success('Done!', 'Report validated successfully.')
//   CwModal.error('Failed', 'Could not reach the server.')
//   CwModal.hide()                         — close whatever is open
//
// Only one modal exists in the DOM at a time (singleton shell).
// ============================================================

const CwModal = (() => {
    const SHELL_ID = 'cwModalShell';

    // ── Ensure the shell exists ───────────────────────────────────────────
    function _ensureShell() {
        if (document.getElementById(SHELL_ID)) return;

        const shell = document.createElement('div');
        shell.id = SHELL_ID;
        shell.innerHTML = `
      <div class="cw-modal-backdrop" id="cwModalBackdrop"></div>
      <div class="cw-modal-wrap" id="cwModalWrap" role="dialog" aria-modal="true">
        <div class="cw-modal-box" id="cwModalBox">
          <div class="cw-modal-icon-wrap" id="cwModalIconWrap"></div>
          <div class="cw-modal-title" id="cwModalTitle"></div>
          <div class="cw-modal-message" id="cwModalMessage"></div>
          <div class="cw-modal-actions" id="cwModalActions"></div>
        </div>
      </div>`;
        document.body.appendChild(shell);

        // Backdrop click closes dismissible modals
        document.getElementById('cwModalBackdrop')
            .addEventListener('click', () => {
                if (document.getElementById(SHELL_ID).dataset.dismissible === 'true') {
                    CwModal.hide();
                }
            });
    }

    // ── Show helper ───────────────────────────────────────────────────────
    function _show({
        variant,
        title,
        message,
        actionLabel,
        onAction,
        dismissible = true
    }) {
        _ensureShell();
        const shell = document.getElementById(SHELL_ID);
        const iconWrap = document.getElementById('cwModalIconWrap');
        const titleEl = document.getElementById('cwModalTitle');
        const msgEl = document.getElementById('cwModalMessage');
        const actionsEl = document.getElementById('cwModalActions');
        const box = document.getElementById('cwModalBox');

        // Reset classes
        box.className = 'cw-modal-box';

        shell.dataset.dismissible = String(dismissible);

        // ── Variant config ────────────────────────────────────────────────
        const cfg = {
            loading: {
                iconHtml: `<div class="cw-modal-spinner"></div>`,
                boxClass: 'cw-modal-box--loading',
                showActions: false,
            },
            success: {
                iconHtml: `<span class="material-symbols-outlined cw-modal-icon cw-modal-icon--success">check_circle</span>`,
                boxClass: 'cw-modal-box--success',
                showActions: true,
            },
            error: {
                iconHtml: `<span class="material-symbols-outlined cw-modal-icon cw-modal-icon--error">error</span>`,
                boxClass: 'cw-modal-box--error',
                showActions: true,
            },
        } [variant] || cfg.error;

        box.classList.add(cfg.boxClass);
        iconWrap.innerHTML = cfg.iconHtml;
        titleEl.textContent = title || '';
        msgEl.textContent = message || '';
        titleEl.style.display = title ? '' : 'none';
        msgEl.style.display = message ? '' : 'none';

        // Actions
        actionsEl.innerHTML = '';
        if (cfg.showActions) {
            const btn = document.createElement('button');
            btn.className = 'cw-modal-btn';
            btn.textContent = actionLabel || 'OK';
            btn.classList.add(variant === 'success' ? 'cw-modal-btn--success' : 'cw-modal-btn--error');
            btn.addEventListener('click', () => {
                CwModal.hide();
                if (typeof onAction === 'function') onAction();
            });
            actionsEl.appendChild(btn);
        }

        // Animate in
        shell.classList.add('cw-modal--active');
        requestAnimationFrame(() => {
            requestAnimationFrame(() => box.classList.add('cw-modal-box--visible'));
        });
    }

    // ── Public API ────────────────────────────────────────────────────────
    return {
        loading(message = 'Please wait...') {
            _show({
                variant: 'loading',
                message,
                dismissible: false
            });
        },

        success(title, message, {
            actionLabel = 'OK',
            onAction
        } = {}) {
            _show({
                variant: 'success',
                title,
                message,
                actionLabel,
                onAction,
                dismissible: false
            });
        },

        error(title, message, {
            actionLabel = 'Close',
            onAction
        } = {}) {
            _show({
                variant: 'error',
                title,
                message,
                actionLabel,
                onAction,
                dismissible: true
            });
        },

        hide() {
            const shell = document.getElementById(SHELL_ID);
            if (!shell) return;
            const box = document.getElementById('cwModalBox');
            if (box) box.classList.remove('cw-modal-box--visible');
            setTimeout(() => shell.classList.remove('cw-modal--active'), 220);
        },
    };
})();

// ============================================================
// Skeleton helpers
// ============================================================
//
// Usage:
//   Skeleton.box(width, height, radius)       — returns HTML string
//   Skeleton.text(width)                      — slim text-line placeholder
//   Skeleton.row(cols)                        — table row of skeleton cells
//   Skeleton.tableRows(rowCount, colCount)    — full tbody placeholder
//   Skeleton.card()                           — stat-card placeholder
//   Skeleton.injectTableRows(tbodyId, rows, cols) — inject & auto-remove
//
// Skeletons remove themselves when real content is inserted via
// Skeleton.clear(tbodyId).
// ============================================================

const Skeleton = (() => {
    const box = (w = '100%', h = 14, r = 6) =>
        `<div class="sk-box" style="width:${typeof w === 'number' ? w + 'px' : w};height:${h}px;border-radius:${r}px"></div>`;

    const text = (w = '80%') => box(w, 13, 6);

    const cell = (w = '80%') =>
        `<td><div class="sk-cell">${box(w, 13)}</div></td>`;

    const row = (cols = 6) =>
        `<tr class="sk-row">${Array.from({ length: cols }, (_, i) =>
            cell(i === 0 ? '60%' : i === cols - 1 ? '40%' : '75%')
        ).join('')}</tr>`;

    const tableRows = (rowCount = 5, colCount = 6) =>
        Array.from({
            length: rowCount
        }, () => row(colCount)).join('');

    const card = () => `
    <div class="sk-card">
      ${box('40%', 12)} 
      <div style="margin-top:10px">${box('55%', 28, 4)}</div>
      <div style="margin-top:8px">${text('70%')}</div>
    </div>`;

    const injectTableRows = (tbodyId, rowCount = 5, colCount = 6) => {
        const tbody = document.getElementById(tbodyId);
        if (!tbody) return;
        tbody.innerHTML = tableRows(rowCount, colCount);
    };

    const clear = (tbodyId) => {
        const tbody = document.getElementById(tbodyId);
        if (tbody) {
            tbody.querySelectorAll('.sk-row').forEach(r => r.remove());
        }
    };

    return {
        box,
        text,
        cell,
        row,
        tableRows,
        card,
        injectTableRows,
        clear
    };
})();