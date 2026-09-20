// ============================================================
// CIVILWATCH Admin Dashboard — App Shell
// Handles: Sidebar, Navbar, Notifications Panel, Dark Mode
// ============================================================

// ── API Helper ────────────────────────────────────────────────
const Api = {
    token() {
        return localStorage.getItem('cw_token');
    },

    headers(extra = {}) {
        return {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            ...(this.token() ? {
                'Authorization': `Bearer ${this.token()}`
            } : {}),
            ...extra,
        };
    },

    async get(url, params = {}) {
        const qs = Object.keys(params).length ? '?' + new URLSearchParams(params).toString() : '';
        const res = await fetch(url + qs, {
            method: 'GET',
            headers: this.headers()
        });
        return this._handle(res);
    },

    async post(url, body = {}) {
        const res = await fetch(url, {
            method: 'POST',
            headers: this.headers(),
            body: JSON.stringify(body),
        });
        return this._handle(res);
    },

    async put(url, body = {}) {
        const res = await fetch(url, {
            method: 'PUT',
            headers: this.headers(),
            body: JSON.stringify(body),
        });
        return this._handle(res);
    },

    async delete(url) {
        const res = await fetch(url, {
            method: 'DELETE',
            headers: this.headers()
        });
        return this._handle(res);
    },

    async _handle(res) {
        if (res.status === 401) {
            localStorage.removeItem('cw_token');
            const depth = window.location.pathname.includes('/offices/') ? '../../' : '';
            window.location.href = depth + 'index.html';
            return null;
        }
        return res.json();
    },

    // ── Action helper ─────────────────────────────────────────
    // Use for any user-triggered mutation (validate, assign, status
    // update, delete) that needs loading → success/error feedback.
    //
    // Example:
    //   await Api.action('POST', '/api/admin/citizen-reports/5/validate', {}, {
    //     loading: 'Validating report...',
    //     success: 'Report validated and published.',
    //     errorTitle: 'Validation failed',
    //   });
    //
    // Options:
    //   loading      {string}   loading modal message
    //   success      {string}   success modal message (falsy = toast only)
    //   successTitle {string}   success modal title   (default 'Done!')
    //   errorTitle   {string}   error modal title     (default 'Request Failed')
    //   onSuccess    {function} called after user dismisses success modal
    //   silent       {boolean}  suppress all modals (for background calls)
    // ─────────────────────────────────────────────────────────
    async action(method, url, body = {}, opts = {}) {
        const {
            loading = 'Processing...',
                success = null,
                successTitle = 'Done!',
                errorTitle = 'Request Failed',
                onSuccess = null,
                silent = false,
        } = opts;

        if (!silent) CwModal.loading(loading);

        try {
            let json;
            const m = method.toUpperCase();
            if (m === 'GET') json = await this.get(url, body);
            else if (m === 'POST') json = await this.post(url, body);
            else if (m === 'PUT') json = await this.put(url, body);
            else if (m === 'DELETE') json = await this.delete(url);
            else throw new Error(`Unknown method: ${method}`);

            if (!silent) CwModal.hide();

            // json === null means 401 redirect already happened
            if (json === null) return null;

            if (json.success === false) {
                const msg = json.message || 'An unexpected error occurred.';
                if (!silent) {
                    CwModal.error(errorTitle, msg);
                } else {
                    Utils.showToast(msg, 'error');
                }
                return null;
            }

            // Success
            if (!silent && success) {
                CwModal.success(successTitle, success, {
                    onAction: onSuccess
                });
            } else if (!silent && success === null && onSuccess) {
                // No modal requested — just fire the callback
                onSuccess();
            } else if (!silent && onSuccess) {
                onSuccess();
            }

            if (!silent && success) return json; // caller waits for modal dismiss
            return json;

        } catch (err) {
            if (!silent) {
                CwModal.hide();
                CwModal.error(
                    errorTitle,
                    'Could not reach the server. Check your connection and try again.'
                );
            }
            console.error('[Api.action]', method, url, err);
            return null;
        }
    },
};

// ── Auth Guard ────────────────────────────────────────────────
function requireAuth() {
    const token = localStorage.getItem('cw_token');
    const role = localStorage.getItem('cw_role');
    if (!token || !role) {
        const depth = window.location.pathname.includes('/offices/') ? '../../' : '';
        window.location.href = depth + 'index.html';
        return false;
    }
    return true;
}

// ── App Shell ─────────────────────────────────────────────────
const App = {
    sidebarCollapsed: false,

    init() {
        this.renderSidebar();
        this.renderNavbar();
        this.renderNotifPanel();
        this.bindEvents();
        this.setActiveNav();
        this.loadTheme();
        this.loadNotifications();
        this.startNotifPolling();
    },

    // ── Role helpers ──────────────────────────────────────────
    getRole() {
        return localStorage.getItem('cw_role') || 'super_admin';
    },
    getName() {
        return localStorage.getItem('cw_name') || 'Super Administrator';
    },
    getTitle() {
        return localStorage.getItem('cw_title') || 'Super Admin';
    },
    getInitials() {
        return this.getName().split(' ').map(w => w[0]).slice(0, 2).join('').toUpperCase();
    },

    // ── Sidebar ───────────────────────────────────────────────
    renderSidebar() {
        const sidebar = document.getElementById('sidebar');
        if (!sidebar) return;

        const role = this.getRole();
        const depth = window.location.pathname.includes('/offices/') ? '../../' : '';

        // Logo
        let logoBrand = '';
        if (role === 'ceo') {
            logoBrand = `
        <div class="sidebar-logo">
          <div class="sidebar-logo-icon" style="background:rgba(255,255,255,0.15);">
            <span class="material-symbols-outlined">business</span>
          </div>
          <div class="sidebar-logo-text">
            <div class="sidebar-logo-title" style="font-size:11px;line-height:1.3;">CITY ENGINEERING<br>OFFICE</div>
          </div>
        </div>`;
        } else if (role === 'cenro') {
            logoBrand = `
        <div class="sidebar-logo">
          <div class="sidebar-logo-icon" style="background:rgba(255,255,255,0.15);">
            <span class="material-symbols-outlined">eco</span>
          </div>
          <div class="sidebar-logo-text">
            <div class="sidebar-logo-title" style="font-size:11px;line-height:1.3;">CENRO</div>
            <div class="sidebar-logo-subtitle">Environmental Office</div>
          </div>
        </div>`;
        } else {
            logoBrand = `
        <div class="sidebar-logo">
          <div class="sidebar-logo-icon">
            <span class="material-symbols-outlined">shield</span>
          </div>
          <div class="sidebar-logo-text">
            <div class="sidebar-logo-title">CIVILWATCH</div>
            <div class="sidebar-logo-subtitle">Digos City</div>
          </div>
        </div>`;
        }

        // Nav items
        let navItems = '';
        if (role === 'super_admin') {
            navItems = `
        <a class="nav-item" href="${depth}dashboard.html" data-page="dashboard">
          <span class="material-symbols-outlined">dashboard</span>
          <span class="nav-item-label">Dashboard</span>
        </a>
        <a class="nav-item" href="${depth}pending-reports.html" data-page="pending-reports">
          <span class="material-symbols-outlined">pending_actions</span>
          <span class="nav-item-label">Pending Reports</span>
          <span class="nav-badge" id="pendingBadge">0</span>
        </a>
        <a class="nav-item" href="${depth}assign-office.html" data-page="assign-office">
          <span class="material-symbols-outlined">assignment_ind</span>
          <span class="nav-item-label">Assign Office</span>
        </a>
        <a class="nav-item" href="${depth}monitoring.html" data-page="monitoring">
          <span class="material-symbols-outlined">track_changes</span>
          <span class="nav-item-label">Monitoring</span>
        </a>
        <a class="nav-item" href="${depth}gis-map.html" data-page="gis-map">
          <span class="material-symbols-outlined">map</span>
          <span class="nav-item-label">GIS Map</span>
        </a>
        <a class="nav-item" href="${depth}analytics.html" data-page="analytics">
          <span class="material-symbols-outlined">bar_chart</span>
          <span class="nav-item-label">Analytics</span>
        </a>
        <a class="nav-item" href="${depth}resolved-reports.html" data-page="resolved-reports">
          <span class="material-symbols-outlined">task_alt</span>
          <span class="nav-item-label">Resolved Reports</span>
        </a>
        <a class="nav-item" href="${depth}users.html" data-page="users">
          <span class="material-symbols-outlined">group</span>
          <span class="nav-item-label">Users</span>
        </a>
        <a class="nav-item" href="${depth}settings.html" data-page="settings">
          <span class="material-symbols-outlined">settings</span>
          <span class="nav-item-label">Settings</span>
        </a>`;
        } else if (role === 'ceo') {
            navItems = `
        <a class="nav-item" href="${depth}offices/ceo/dashboard.html" data-page="dashboard">
          <span class="material-symbols-outlined">dashboard</span>
          <span class="nav-item-label">Dashboard</span>
        </a>
        <a class="nav-item" href="${depth}offices/ceo/reports.html" data-page="reports">
          <span class="material-symbols-outlined">assignment</span>
          <span class="nav-item-label">My Assigned Reports</span>
        </a>
        <a class="nav-item" href="${depth}offices/ceo/inprogress.html" data-page="inprogress">
          <span class="material-symbols-outlined">autorenew</span>
          <span class="nav-item-label">Active Reports</span>
        </a>
        <a class="nav-item" href="${depth}offices/ceo/resolved.html" data-page="resolved">
          <span class="material-symbols-outlined">task_alt</span>
          <span class="nav-item-label">Resolved Reports</span>
        </a>
        <a class="nav-item" href="${depth}offices/ceo/map.html" data-page="map">
          <span class="material-symbols-outlined">map</span>
          <span class="nav-item-label">Map</span>
        </a>
        <a class="nav-item" href="${depth}offices/ceo/analytics.html" data-page="analytics">
          <span class="material-symbols-outlined">bar_chart</span>
          <span class="nav-item-label">Analytics</span>
        </a>
        <a class="nav-item" href="${depth}offices/ceo/settings.html" data-page="settings">
          <span class="material-symbols-outlined">settings</span>
          <span class="nav-item-label">Settings</span>
        </a>`;
        } else if (role === 'cenro') {
            navItems = `
        <a class="nav-item" href="${depth}offices/cenro/dashboard.html" data-page="dashboard">
          <span class="material-symbols-outlined">dashboard</span>
          <span class="nav-item-label">Dashboard</span>
        </a>
        <a class="nav-item" href="${depth}offices/cenro/reports.html" data-page="reports">
          <span class="material-symbols-outlined">assignment</span>
          <span class="nav-item-label">My Assigned Reports</span>
        </a>
        <a class="nav-item" href="${depth}offices/cenro/inprogress.html" data-page="inprogress">
          <span class="material-symbols-outlined">autorenew</span>
          <span class="nav-item-label">Active Reports</span>
        </a>
        <a class="nav-item" href="${depth}offices/cenro/resolved.html" data-page="resolved">
          <span class="material-symbols-outlined">task_alt</span>
          <span class="nav-item-label">Resolved Reports</span>
        </a>
        <a class="nav-item" href="${depth}offices/cenro/map.html" data-page="map">
          <span class="material-symbols-outlined">map</span>
          <span class="nav-item-label">Map</span>
        </a>
        <a class="nav-item" href="${depth}offices/cenro/analytics.html" data-page="analytics">
          <span class="material-symbols-outlined">bar_chart</span>
          <span class="nav-item-label">Analytics</span>
        </a>
        <a class="nav-item" href="${depth}offices/cenro/settings.html" data-page="settings">
          <span class="material-symbols-outlined">settings</span>
          <span class="nav-item-label">Settings</span>
        </a>`;
        }

        const logoutLink = `
      <a class="nav-item" href="#" onclick="App.logout(event)" style="margin-top:4px;">
        <span class="material-symbols-outlined">logout</span>
        <span class="nav-item-label">Logout</span>
      </a>`;

        sidebar.innerHTML = `
      ${logoBrand}
      <nav class="sidebar-nav">
        ${navItems}
        ${logoutLink}
      </nav>
      <div class="sidebar-footer">
        <div class="sidebar-user">
          <div class="sidebar-user-avatar">${this.getInitials()}</div>
          <div class="sidebar-user-info">
            <div class="sidebar-user-name">${this.getName()}</div>
            <div class="sidebar-user-role">${this.getTitle()}</div>
          </div>
        </div>
        <div class="sidebar-user-status" style="padding:2px 12px 8px;margin-left:2px;">
          <div class="status-dot"></div>
          <span style="font-size:11px;color:rgba(255,255,255,0.5)">Online</span>
        </div>
      </div>`;

        if (role === 'cenro') {
            sidebar.style.background = 'linear-gradient(180deg, #166534 0%, #14532d 100%)';
        }

        // Update pending badge from API
        if (role === 'super_admin') {
            Api.get('/api/analytics/summary').then(json => {
                if (!json || !json.success) return;
                const badge = document.getElementById('pendingBadge');
                if (badge) badge.textContent = json.data.pending_validation || 0;
            }).catch(() => {});
        }
    },

    // ── Navbar ────────────────────────────────────────────────
    renderNavbar() {
        const navbar = document.getElementById('navbar');
        if (!navbar) return;
        navbar.innerHTML = `
      <div class="navbar-left">
        <button class="navbar-toggle" id="sidebarToggle" title="Toggle sidebar">
          <span class="material-symbols-outlined">menu</span>
        </button>
        <div class="navbar-search">
          <span class="material-symbols-outlined navbar-search-icon">search</span>
          <input type="text" placeholder="Search reports, locations..." id="globalSearch" />
        </div>
      </div>
      <div class="navbar-right">
        <button class="navbar-icon-btn" id="darkModeBtn" title="Toggle Dark Mode">
          <span class="material-symbols-outlined" id="darkModeIcon">dark_mode</span>
        </button>
        <button class="navbar-icon-btn" id="notifBtn" title="Notifications">
          <span class="material-symbols-outlined">notifications</span>
          <span class="notif-badge" id="notifBadge"></span>
        </button>
        <div class="navbar-profile" id="profileBtn">
          <div class="navbar-avatar">${this.getInitials()}</div>
          <div class="navbar-profile-info">
            <span class="navbar-profile-name">${this.getName()}</span>
            <span class="navbar-profile-role">${this.getTitle()}</span>
          </div>
          <span class="material-symbols-outlined">expand_more</span>
        </div>
      </div>`;
    },

    // ── Notifications Panel ───────────────────────────────────
    renderNotifPanel() {
        if (document.getElementById('notifPanel')) return;

        const panel = document.createElement('div');
        panel.className = 'notif-panel';
        panel.id = 'notifPanel';
        panel.innerHTML = `
      <div class="notif-panel-header">
        <div class="notif-panel-title-wrap">
          <span class="notif-panel-title">Notifications</span>
          <span class="notif-count-badge" id="notifCountBadge">0</span>
        </div>
        <div class="notif-panel-actions">
          <button class="notif-mark-read" id="markAllReadBtn">Mark all as read</button>
          <button class="notif-close" id="notifClose">
            <span class="material-symbols-outlined">close</span>
          </button>
        </div>
      </div>
      <div class="notif-list" id="notifList">
        <div style="text-align:center;padding:24px;color:var(--gray-400);font-size:13px;">Loading notifications...</div>
      </div>
      <div class="notif-panel-footer">
        <span class="notif-view-all">
          <span class="material-symbols-outlined">notifications</span>
          View all notifications
          <span class="material-symbols-outlined">arrow_forward</span>
        </span>
      </div>`;
        document.body.appendChild(panel);

        const overlay = document.createElement('div');
        overlay.className = 'overlay';
        overlay.id = 'notifOverlay';
        overlay.addEventListener('click', () => this.closeNotif());
        document.body.appendChild(overlay);
    },

    // ── Events ────────────────────────────────────────────────
    bindEvents() {
        document.addEventListener('click', e => {
            if (e.target.closest('#sidebarToggle')) this.toggleSidebar();
            if (e.target.closest('#notifBtn')) this.openNotif();
            if (e.target.closest('#notifClose')) this.closeNotif();
            if (e.target.closest('#markAllReadBtn')) this.markAllRead();
            if (e.target.closest('#darkModeBtn')) this.toggleDarkMode();
        });
    },

    toggleSidebar() {
        const sidebar = document.getElementById('sidebar');
        const mainArea = document.getElementById('mainArea');
        const navbar = document.getElementById('navbar');
        this.sidebarCollapsed = !this.sidebarCollapsed;
        if (sidebar) sidebar.classList.toggle('collapsed', this.sidebarCollapsed);
        if (mainArea) mainArea.classList.toggle('sidebar-collapsed', this.sidebarCollapsed);
        if (navbar) navbar.classList.toggle('sidebar-collapsed', this.sidebarCollapsed);
    },

    openNotif() {
        const panel = document.getElementById('notifPanel');
        const overlay = document.getElementById('notifOverlay');
        if (panel) panel.classList.add('open');
        if (overlay) overlay.classList.add('active');
        document.querySelectorAll('.leaflet-control-container').forEach(el => {
            el.style.visibility = 'hidden';
        });
    },

    closeNotif() {
        const panel = document.getElementById('notifPanel');
        const overlay = document.getElementById('notifOverlay');
        if (panel) panel.classList.remove('open');
        if (overlay) overlay.classList.remove('active');
        document.querySelectorAll('.leaflet-control-container').forEach(el => {
            el.style.visibility = '';
        });
    },

    markAllRead() {
        document.querySelectorAll('.notif-item.unread').forEach(el => {
            el.classList.remove('unread');
            const dot = el.querySelector('.unread-dot');
            if (dot) dot.remove();
        });
        const badge = document.getElementById('notifBadge');
        if (badge) badge.textContent = '';
        const countBadge = document.getElementById('notifCountBadge');
        if (countBadge) countBadge.textContent = '0';
        Utils.showToast('All notifications marked as read', 'success');
        Api.action('POST', '/api/notifications/read-all', {}, {
            silent: true
        }).catch(() => {});
    },

    // ── Dark Mode ─────────────────────────────────────────────
    toggleDarkMode() {
        const html = document.documentElement;
        const isDark = html.getAttribute('data-theme') === 'dark';
        const newTheme = isDark ? 'light' : 'dark';
        html.setAttribute('data-theme', newTheme);
        localStorage.setItem('theme', newTheme);
        const icon = document.getElementById('darkModeIcon');
        if (icon) icon.textContent = isDark ? 'dark_mode' : 'light_mode';
        if (typeof Utils !== 'undefined') Utils.showToast(`${isDark ? 'Light' : 'Dark'} mode enabled`, 'info');
    },

    loadTheme() {
        const saved = localStorage.getItem('theme') || 'light';
        document.documentElement.setAttribute('data-theme', saved);
        const icon = document.getElementById('darkModeIcon');
        if (icon) icon.textContent = saved === 'dark' ? 'light_mode' : 'dark_mode';
    },

    setActiveNav() {
        const page = document.body.dataset.page;
        if (!page) return;
        document.querySelectorAll('.nav-item').forEach(el => {
            el.classList.toggle('active', el.dataset.page === page);
        });
    },

    // ── Logout ────────────────────────────────────────────────
    logout(e) {
        if (e) e.preventDefault();
        CwModal.loading('Logging out...');
        Api.post('/api/logout')
            .catch(() => {})
            .finally(() => {
                ['cw_token', 'cw_role', 'cw_name', 'cw_title', 'cw_email'].forEach(k => localStorage.removeItem(k));
                const depth = window.location.pathname.includes('/offices/') ? '../../' : '';
                window.location.href = depth + 'index.html';
            });
    },

    // ── Notifications from API ────────────────────────────────
    async loadNotifications() {
        try {
            const json = await Api.get('/api/notifications');
            if (!json || !json.success) return;

            const {
                notifications,
                unread_count
            } = json.data;

            const badge = document.getElementById('notifBadge');
            if (badge) badge.textContent = unread_count > 0 ? unread_count : '';

            const countBadge = document.getElementById('notifCountBadge');
            if (countBadge) countBadge.textContent = unread_count;

            const list = document.getElementById('notifList');
            if (!list) return;

            if (!notifications || notifications.length === 0) {
                list.innerHTML = `<div style="text-align:center;padding:24px;color:var(--gray-400);font-size:13px;">No notifications yet.</div>`;
                return;
            }

            const iconMap = {
                report_submitted: {
                    icon: 'description',
                    cls: 'submit'
                },
                report_assigned: {
                    icon: 'person_add',
                    cls: 'assign'
                },
                status_update: {
                    icon: 'autorenew',
                    cls: 'progress'
                },
                report_resolved: {
                    icon: 'check_circle',
                    cls: 'resolved'
                },
                system: {
                    icon: 'notifications',
                    cls: 'system'
                },
            };

            list.innerHTML = notifications.map(n => {
                const im = iconMap[n.type] || {
                    icon: 'notifications',
                    cls: 'system'
                };
                const mins = Math.floor((Date.now() - new Date(n.created_at)) / 60000);
                const time = (typeof Utils !== 'undefined' && Utils.relativeTime) ?
                    Utils.relativeTime(mins) : n.created_at;
                const label = n.type.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
                return `
          <div class="notif-item ${n.is_read ? '' : 'unread'}" data-id="${n.id}">
            <div class="notif-icon ${im.cls}">
              <span class="material-symbols-outlined">${im.icon}</span>
            </div>
            <div class="notif-content">
              <div class="notif-title">${label}</div>
              <div class="notif-desc">${n.message}</div>
              <div class="notif-time">${time}</div>
            </div>
            ${n.is_read ? '' : '<div class="unread-dot"></div>'}
          </div>`;
            }).join('');
        } catch (_) {
            // Non-critical — fail silently
        }
    },

    startNotifPolling() {
        setInterval(async () => {
            try {
                const json = await Api.get('/api/notifications/unread-count');
                if (!json || !json.success) return;
                const count = json.data.unread_count;
                const badge = document.getElementById('notifBadge');
                if (badge) badge.textContent = count > 0 ? count : '';
            } catch (_) {}
        }, 30000);
    },
};

document.addEventListener('DOMContentLoaded', () => {
    App.init();
});