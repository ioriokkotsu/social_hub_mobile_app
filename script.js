window.tailwind = window.tailwind || {};
window.tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: '#2E7D32',
                        secondary: '#66BB6A',
                        accent: '#FFC107',
                        appbg: '#F5F7F5',
                        surface: '#FFFFFF',
                        textMain: '#1B1B1B',
                        textMuted: '#6B6B6B'
                    },
                    fontFamily: {
                        poppins: ['Poppins', 'sans-serif'],
                        inter: ['Inter', 'sans-serif'],
                    },
                    boxShadow: {
                        'soft': '0 4px 20px -4px rgba(0,0,0,0.05)',
                        'floating': '0 10px 40px -10px rgba(46,125,50,0.15)',
                    }
                }
            }
        }

function navigate(screenId) {
            document.querySelectorAll('.screen').forEach(el => el.classList.remove('active'));
            document.getElementById('screen-' + screenId).classList.add('active');

            const bottomNav = document.getElementById('bottom-nav');
            // Hide bottom nav on full screen/auth/sub-flows
            if (['splash', 'onboarding', 'login', 'roles', 'project', 'admin', 'admin-create-event', 'admin-edit-event', 'admin-event-detail', 'admin-volunteer-list', 'admin-pending-list', 'join-form', 'log-hours-form', 'ngo-profile', 'task-detail', 'joined-project'].includes(screenId)) {
                bottomNav.classList.add('hidden');
            } else {
                bottomNav.classList.remove('hidden');
            }
        }

        function switchAdminTab(tab) {
            // Hide all tab content
            ['overview', 'manage', 'requests'].forEach(t => {
                document.getElementById('admin-' + t).style.display = 'none';
                
                // Reset tab styles to default unselected (text-white/80)
                const btn = document.getElementById('tab-' + t);
                btn.className = 'flex-1 py-2 text-white/80 font-medium text-sm rounded-xl hover:text-white transition-all whitespace-nowrap px-4 cursor-pointer';
            });
            
            // Show active tab
            document.getElementById('admin-' + tab).style.display = 'block';
            
            // Highlight active tab (bg-white text-textMain)
            const activeBtn = document.getElementById('tab-' + tab);
            activeBtn.className = 'flex-1 py-2 bg-white text-textMain rounded-xl font-bold text-sm shadow-sm transition-all whitespace-nowrap px-4 cursor-pointer';
        }

        function switchReqTab(tab) {
            const indicator = document.getElementById('req-tab-indicator');
            const btnApps = document.getElementById('req-btn-apps');
            const btnHours = document.getElementById('req-btn-hours');
            const secApps = document.getElementById('req-section-apps');
            const secHours = document.getElementById('req-section-hours');

            if (tab === 'apps') {
                indicator.style.transform = 'translateX(0)';
                btnApps.classList.replace('text-textMuted', 'text-textMain');
                btnHours.classList.replace('text-textMain', 'text-textMuted');
                
                secHours.classList.add('hidden');
                secHours.classList.remove('block');
                secApps.classList.remove('hidden');
                secApps.classList.add('block');
            } else if (tab === 'hours') {
                indicator.style.transform = 'translateX(100%)'; 
                
                btnHours.classList.replace('text-textMuted', 'text-textMain');
                btnApps.classList.replace('text-textMain', 'text-textMuted');
                
                secApps.classList.add('hidden');
                secApps.classList.remove('block');
                secHours.classList.remove('hidden');
                secHours.classList.add('block');
            }
        }

        function switchVolTab(tab) {
            const indicator = document.getElementById('vol-tab-indicator');
            const btnTasks = document.getElementById('vol-btn-tasks');
            const btnProjects = document.getElementById('vol-btn-projects');
            const secTasks = document.getElementById('vol-section-tasks');
            const secProjects = document.getElementById('vol-section-projects');

            if (tab === 'tasks') {
                indicator.style.transform = 'translateX(0)';
                btnTasks.classList.replace('text-textMuted', 'text-textMain');
                btnProjects.classList.replace('text-textMain', 'text-textMuted');
                
                secProjects.classList.add('hidden');
                secProjects.classList.remove('block');
                secTasks.classList.remove('hidden');
                secTasks.classList.add('block');
            } else if (tab === 'projects') {
                indicator.style.transform = 'translateX(100%)'; 
                
                btnProjects.classList.replace('text-textMuted', 'text-textMain');
                btnTasks.classList.replace('text-textMain', 'text-textMuted');
                
                secTasks.classList.add('hidden');
                secTasks.classList.remove('block');
                secProjects.classList.remove('hidden');
                secProjects.classList.add('block');
            }
        }

        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            const overlay = document.getElementById('sidebar-overlay');
            if (sidebar.classList.contains('-translate-x-full')) {
                sidebar.classList.remove('-translate-x-full');
                overlay.classList.remove('hidden');
            } else {
                sidebar.classList.add('-translate-x-full');
                overlay.classList.add('hidden');
            }
        }

        // NEW: Popup handling for Volunteer Info
        function openVolunteerPopup(name, role, email, phone, occupation, hours, imgUrl) {
            document.getElementById('vol-popup-name').innerText = name;
            document.getElementById('vol-popup-role').innerText = role;
            document.getElementById('vol-popup-email').innerText = email;
            document.getElementById('vol-popup-phone').innerText = phone;
            document.getElementById('vol-popup-occupation').innerText = occupation;
            document.getElementById('vol-popup-hours').innerText = hours;
            document.getElementById('vol-popup-img').src = imgUrl;
            
            const sheet = document.getElementById('volunteer-detail-sheet');
            sheet.classList.remove('hidden');
            sheet.classList.add('flex');
        }

        function closeVolunteerPopup() {
            const sheet = document.getElementById('volunteer-detail-sheet');
            sheet.classList.add('hidden');
            sheet.classList.remove('flex');
        }

        // Auto Start

function showToast(message) {
  const toast = document.getElementById('toast');
  const text = document.getElementById('toast-msg');
  if (!toast || !text) return;

  text.innerText = message;
  toast.classList.remove('opacity-0', 'pointer-events-none', 'translate-y-[-20px]');

  if (window.__toastTimer) {
    clearTimeout(window.__toastTimer);
  }

  window.__toastTimer = setTimeout(() => {
    toast.classList.add('opacity-0', 'pointer-events-none', 'translate-y-[-20px]');
  }, 2200);
}

function initializeApp() {
  if (window.lucide && typeof window.lucide.createIcons === 'function') {
    window.lucide.createIcons();
  }

  setTimeout(() => { navigate('onboarding'); }, 1500);
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeApp);
} else {
  initializeApp();
}
