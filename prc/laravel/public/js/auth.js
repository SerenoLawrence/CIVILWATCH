/**
 * auth.js — CivilWatch Admin
 *
 * Handles:
 *  - Login form submission
 *  - Token storage / retrieval
 *  - Auth guard (redirect to login if not logged in)
 *  - Logout
 *  - Shared fetch helper with Authorization header
 */

const API_BASE = '/api';

// ----------------------------------------------------------------
// Token helpers — store token in localStorage
// ----------------------------------------------------------------

function getToken() {
    return localStorage.getItem('cw_token');
}

function setToken(token) {
    localStorage.setItem('cw_token', token);
}

function removeToken() {
    localStorage.removeItem('cw_token');
    localStorage.removeItem('cw_user');
}

function getUser() {
    const raw = localStorage.getItem('cw_user');
    try {
        return raw ? JSON.parse(raw) : null;
    } catch {
        return null;
    }
}

function setUser(user) {
    localStorage.setItem('cw_user', JSON.stringify(user));
}

// ----------------------------------------------------------------
// Auth guard — call on any protected page (dashboard, users)
// If no token found, redirect to login immediately.
// ----------------------------------------------------------------

function requireAuth() {
    if (!getToken()) {
        window.location.href = '/login.html';
    }
}

// ----------------------------------------------------------------
// Shared API fetch helper
// Automatically adds Authorization header and JSON content type.
// ----------------------------------------------------------------

async function apiFetch(endpoint, options = {}) {
    const token = getToken();

    const headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...(token ? {
            'Authorization': `Bearer ${token}`
        } : {}),
        ...(options.headers || {}),
    };

    const response = await fetch(`${API_BASE}${endpoint}`, {
        ...options,
        headers,
    });

    // If server says 401 Unauthorized — token expired or invalid
    if (response.status === 401) {
        removeToken();
        window.location.href = '/login.html';
        return;
    }

    const data = await response.json();
    return {
        ok: response.ok,
        status: response.status,
        data
    };
}

// ----------------------------------------------------------------
// Show / hide an alert element
// ----------------------------------------------------------------

function showAlert(elementId, message, type = 'error') {
    const el = document.getElementById(elementId);
    if (!el) return;
    el.textContent = message;
    el.className = `alert alert-${type} show`;
}

function hideAlert(elementId) {
    const el = document.getElementById(elementId);
    if (!el) return;
    el.className = 'alert';
    el.textContent = '';
}

// ----------------------------------------------------------------
// Set field-level validation error
// ----------------------------------------------------------------

function setFieldError(fieldId, errorId, message) {
    const field = document.getElementById(fieldId);
    const error = document.getElementById(errorId);
    if (field) field.classList.add('is-error');
    if (error) error.textContent = message;
}

function clearFieldErrors(fields) {
    fields.forEach(({
        fieldId,
        errorId
    }) => {
        const field = document.getElementById(fieldId);
        const error = document.getElementById(errorId);
        if (field) field.classList.remove('is-error');
        if (error) error.textContent = '';
    });
}

// ----------------------------------------------------------------
// Populate topbar username on protected pages
// ----------------------------------------------------------------

function populateTopbar() {
    const user = getUser();
    const el = document.getElementById('topbarUserName');
    if (el && user) {
        el.textContent = user.name;
    }
}

// ----------------------------------------------------------------
// Logout handler — attached to any element with id="logoutBtn"
// ----------------------------------------------------------------

async function handleLogout() {
    try {
        await apiFetch('/logout', {
            method: 'POST'
        });
    } catch (e) {
        // Even if the API call fails, still clear local storage
    }
    removeToken();
    window.location.href = '/login.html';
}

// ----------------------------------------------------------------
// Login form — only runs on login.html
// ----------------------------------------------------------------

const loginForm = document.getElementById('loginForm');

if (loginForm) {
    // If already logged in, skip login page
    if (getToken()) {
        window.location.href = '/dashboard.html';
    }

    loginForm.addEventListener('submit', async function(e) {
        e.preventDefault();

        const emailEl = document.getElementById('email');
        const passwordEl = document.getElementById('password');
        const loginBtn = document.getElementById('loginBtn');

        const email = emailEl.value.trim();
        const password = passwordEl.value;

        // Clear previous errors
        hideAlert('loginError');
        clearFieldErrors([{
                fieldId: 'email',
                errorId: 'emailError'
            },
            {
                fieldId: 'password',
                errorId: 'passwordError'
            },
        ]);

        // Basic client-side validation (server also validates)
        let hasError = false;

        if (!email) {
            setFieldError('email', 'emailError', 'Email is required.');
            hasError = true;
        } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            setFieldError('email', 'emailError', 'Please enter a valid email.');
            hasError = true;
        }

        if (!password) {
            setFieldError('password', 'passwordError', 'Password is required.');
            hasError = true;
        }

        if (hasError) return;

        // Show loading modal while request is in-flight
        if (typeof CwModal !== 'undefined') CwModal.loading('Signing you in...');
        loginBtn.disabled = true;

        try {
            const result = await apiFetch('/login', {
                method: 'POST',
                body: JSON.stringify({
                    email,
                    password
                }),
            });

            if (typeof CwModal !== 'undefined') CwModal.hide();

            if (result.data.success) {
                // Save token and user info
                setToken(result.data.data.token);
                setUser(result.data.data.user);

                // Show brief success modal then redirect
                if (typeof CwModal !== 'undefined') {
                    const name = result.data.data.user ? .name ? .split(' ')[0] || 'Admin';
                    CwModal.success('Welcome back!', `Logged in as ${name}. Redirecting…`, {
                        actionLabel: 'Continue',
                        onAction: () => {
                            window.location.href = '/dashboard.html';
                        },
                    });
                    // Auto-redirect after 1.4s even without clicking
                    setTimeout(() => {
                        window.location.href = '/dashboard.html';
                    }, 1400);
                } else {
                    window.location.href = '/dashboard.html';
                }
            } else {
                const msg = result.data.message || 'Login failed. Check your credentials.';
                if (typeof CwModal !== 'undefined') {
                    CwModal.error('Login Failed', msg);
                } else {
                    showAlert('loginError', msg);
                }
            }

        } catch (err) {
            if (typeof CwModal !== 'undefined') {
                CwModal.hide();
                CwModal.error('Connection Error', 'Could not reach the server. Check your connection.');
            } else {
                showAlert('loginError', 'Network error. Please check your connection.');
            }
        } finally {
            loginBtn.disabled = false;
        }
    });
}

// ----------------------------------------------------------------
// Attach logout button on protected pages
// ----------------------------------------------------------------

const logoutBtn = document.getElementById('logoutBtn');
if (logoutBtn) {
    logoutBtn.addEventListener('click', handleLogout);
}