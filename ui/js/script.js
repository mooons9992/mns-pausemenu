// MNS Pause Menu - Client-side JavaScript
// Modern implementation with better performance and features

// State management
let currentTab = 'server_info';
let playerData = null;
let discordInfo = null;
let serverInfo = null;
let customButtons = [];
let isAdmin = false;
let onlinePlayers = [];

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    // Notify the resource that the UI is ready
    fetch(`https://mns-pausemenu/ready`);
    
    // Setup event listeners for main buttons
    setupEventListeners();
    
    // Get player's avatar
    getDiscordAvatar();
    
    // Get custom buttons
    getCustomButtons();
});

// Main event listener for NUI messages
window.addEventListener('message', (event) => {
    const data = event.data;

    switch (data.type) {
        case 'open':
            showMenu();
            updateMenu(data.data);
            break;
        case 'close':
            hideMenu();
            break;
        case 'update':
            updateMenu(data.data);
            break;
        case 'setServerInfo':
            serverInfo = data.data;
            updateServerInfo();
            break;
        case 'setOnlinePlayers':
            onlinePlayers = data.data;
            updateAdminPanel();
            break;
        case 'showNotification':
            showNotification(data.message, data.notificationType || 'info');
            break;
        case 'updateTabs':
            updateTabVisibility(data.tabs);
            break;
    }
});

// Set up all event listeners
function setupEventListeners() {
    // Main menu buttons
    document.getElementById('settings-btn')?.addEventListener('click', () => {
        fetch(`https://mns-pausemenu/openSettings`);
    });

    document.getElementById('map-btn')?.addEventListener('click', () => {
        changeTab('map');
        fetch(`https://mns-pausemenu/openMap`);
    });

    document.getElementById('exit-btn')?.addEventListener('click', () => {
        showConfirmationModal(
            'Disconnect from server?', 
            'Are you sure you want to disconnect from the server?',
            () => fetch(`https://mns-pausemenu/exit`)
        );
    });

    // Close menu on Escape key
    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape') {
            hideMenu();
            fetch(`https://mns-pausemenu/close`);
        }
    });

    // Tab navigation
    document.querySelectorAll('.tab-button').forEach(button => {
        button.addEventListener('click', () => {
            const tabId = button.getAttribute('data-tab');
            changeTab(tabId);
        });
    });
}

// Update the menu with player data
function updateMenu(data) {
    playerData = data;
    isAdmin = data.isAdmin;
    
    // Update player info
    document.getElementById('player-name').innerText = data.playerName || 'Unknown Player';
    
    // Job information handling
    const jobElement = document.getElementById('job1name');
    if (jobElement) {
        let jobText = data.playerJob;
        // Clean up job text if needed
        if (jobText === 'Unemployed - Unemployed' || jobText === 'Disoccupato - Disoccupato') {
            jobText = 'Unemployed';
        }
        jobElement.innerText = jobText;
    }
    
    // Gang information
    const gangElement = document.getElementById('job2name');
    if (gangElement) {
        if (!data.playerGang || data.playerGang === 'None') {
            document.getElementById('job2').style.display = 'none';
        } else {
            document.getElementById('job2').style.display = 'flex';
            gangElement.innerText = data.playerGang;
        }
    }
    
    // Player ID
    document.getElementById('citizen-id').innerText = data.citizenId || 'Unknown';
    
    // Server stats
    document.getElementById('player-count').innerText = `${data.onlinePlayers}/${data.maxPlayers || 64}`;
    document.getElementById('server-uptime').innerText = data.uptime || '00:00:00';
    
    // Update player stats if available
    updatePlayerStats(data);
    
    // Show/hide admin panel based on permissions
    toggleAdminPanel(data.isAdmin);
    
    // Set the in-game time
    updateGameTime();
}

// Update player statistics
function updatePlayerStats(data) {
    if (!data.stats) return;
    
    const statsContainer = document.getElementById('player-stats');
    if (!statsContainer) return;
    
    // Update hunger/thirst/stress bars if they exist
    const hungerBar = document.getElementById('hunger-bar');
    const thirstBar = document.getElementById('thirst-bar');
    const stressBar = document.getElementById('stress-bar');
    
    if (hungerBar) hungerBar.style.width = `${data.stats.hunger}%`;
    if (thirstBar) thirstBar.style.width = `${data.stats.thirst}%`;
    if (stressBar) stressBar.style.width = `${data.stats.stress}%`;
    
    // Update money displays
    document.getElementById('cash-amount')?.innerText = formatMoney(data.money?.cash || 0);
    document.getElementById('bank-amount')?.innerText = formatMoney(data.money?.bank || 0);
    document.getElementById('crypto-amount')?.innerText = data.money?.crypto || 0;
}

// Toggle admin panel visibility
function toggleAdminPanel(isAdmin) {
    const adminTab = document.getElementById('admin-tab');
    if (adminTab) {
        adminTab.style.display = isAdmin ? 'block' : 'none';
    }
    
    if (isAdmin && currentTab === 'admin') {
        updateAdminPanel();
    }
}

// Update the admin panel with online players
function updateAdminPanel() {
    if (!isAdmin || !onlinePlayers) return;
    
    const playersList = document.getElementById('admin-players-list');
    if (!playersList) return;
    
    playersList.innerHTML = '';
    
    onlinePlayers.forEach(player => {
        const playerItem = document.createElement('div');
        playerItem.className = 'player-item';
        playerItem.innerHTML = `
            <div class="player-item-info">
                <span class="player-item-id">#${player.id}</span>
                <span class="player-item-name">${player.name}</span>
                <span class="player-item-job">${player.job}</span>
                <span class="player-item-ping">${player.ping}ms</span>
            </div>
            <div class="player-item-actions">
                <button class="player-action-btn" data-action="teleport" data-id="${player.id}">
                    <i class="fas fa-map-marker-alt"></i>
                </button>
                <button class="player-action-btn" data-action="bring" data-id="${player.id}">
                    <i class="fas fa-user-plus"></i>
                </button>
                <button class="player-action-btn warning" data-action="kick" data-id="${player.id}">
                    <i class="fas fa-user-slash"></i>
                </button>
            </div>
        `;
        
        playersList.appendChild(playerItem);
    });
    
    // Add event listeners to the action buttons
    document.querySelectorAll('.player-action-btn').forEach(button => {
        button.addEventListener('click', () => {
            const action = button.getAttribute('data-action');
            const playerId = button.getAttribute('data-id');
            
            if (action === 'kick') {
                showPromptModal('Kick Player', 'Enter reason for kick:', (reason) => {
                    fetch(`https://mns-pausemenu/adminAction`, {
                        method: 'POST',
                        body: JSON.stringify({
                            action: 'kick',
                            targetId: playerId,
                            param: reason
                        })
                    });
                });
            } else {
                fetch(`https://mns-pausemenu/adminAction`, {
                    method: 'POST',
                    body: JSON.stringify({
                        action: action,
                        targetId: playerId
                    })
                });
            }
        });
    });
}

// Get player's Discord avatar
async function getDiscordAvatar() {
    try {
        const response = await fetch(`https://mns-pausemenu/GetDiscordAvatar`);
        const data = await response.json();
        
        discordInfo = data;
        const avatarElement = document.getElementById('player-avatar');
        
        if (avatarElement) {
            if (data.avatar) {
                avatarElement.src = data.avatar;
            } else {
                avatarElement.src = "images/guest.png";
            }
        }
    } catch (error) {
        console.error('Failed to get Discord avatar:', error);
    }
}

// Get custom buttons configuration
async function getCustomButtons() {
    try {
        const response = await fetch(`https://mns-pausemenu/GetCustomButtons`);
        const data = await response.json();
        
        customButtons = data;
        renderCustomButtons();
    } catch (error) {
        console.error('Failed to get custom buttons:', error);
    }
}

// Render custom buttons in the UI
function renderCustomButtons() {
    const container = document.getElementById('custom-buttons');
    if (!container || !customButtons || customButtons.length === 0) return;
    
    container.innerHTML = '';
    
    customButtons.forEach(button => {
        const buttonElement = document.createElement('button');
        buttonElement.className = 'menu-btn custom-button';
        buttonElement.innerHTML = `
            <i class="${button.icon || 'fas fa-circle'}"></i>
            <span>${button.label}</span>
        `;
        
        buttonElement.addEventListener('click', () => {
            fetch(`https://mns-pausemenu/triggerButtonAction`, {
                method: 'POST',
                body: JSON.stringify({
                    action: button.action
                })
            });
        });
        
        container.appendChild(buttonElement);
    });
}

// Update server information
function updateServerInfo() {
    if (!serverInfo) return;
    
    document.getElementById('server-name').innerText = serverInfo.name || 'FiveM Server';
    document.getElementById('server-description').innerText = serverInfo.description || '';
}

// Change active tab
function changeTab(tabId) {
    // Hide all tabs
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.remove('active');
    });
    
    // Remove active class from all buttons
    document.querySelectorAll('.tab-button').forEach(button => {
        button.classList.remove('active');
    });
    
    // Show the selected tab
    const selectedTab = document.getElementById(`${tabId}-tab`);
    if (selectedTab) {
        selectedTab.classList.add('active');
    }
    
    // Add active class to the button
    const selectedButton = document.querySelector(`.tab-button[data-tab="${tabId}"]`);
    if (selectedButton) {
        selectedButton.classList.add('active');
    }
    
    currentTab = tabId;
    
    // Refresh tab content if needed
    if (tabId === 'admin' && isAdmin) {
        updateAdminPanel();
    }
}

// Update in-game time display
function updateGameTime() {
    // This would be updated with actual game time from the server
    const now = new Date();
    const hours = now.getHours().toString().padStart(2, '0');
    const minutes = now.getMinutes().toString().padStart(2, '0');
    
    document.getElementById('server-time').innerText = `${hours}:${minutes}`;
}

// Show notification
function showNotification(message, type = 'info') {
    const container = document.getElementById('notification-container');
    if (!container) return;
    
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.innerHTML = `
        <div class="notification-icon">
            <i class="fas ${getNotificationIcon(type)}"></i>
        </div>
        <div class="notification-content">
            <p>${message}</p>
        </div>
    `;
    
    container.appendChild(notification);
    
    // Auto remove after 5 seconds
    setTimeout(() => {
        notification.classList.add('fade-out');
        setTimeout(() => {
            notification.remove();
        }, 500);
    }, 5000);
}

// Get icon for notification type
function getNotificationIcon(type) {
    switch(type) {
        case 'success': return 'fa-check-circle';
        case 'error': return 'fa-times-circle';
        case 'warning': return 'fa-exclamation-triangle';
        default: return 'fa-info-circle';
    }
}

// Show confirmation modal
function showConfirmationModal(title, message, onConfirm) {
    const modalContainer = document.getElementById('modal-container');
    if (!modalContainer) return;
    
    modalContainer.innerHTML = `
        <div class="modal confirmation-modal">
            <div class="modal-header">
                <h3>${title}</h3>
            </div>
            <div class="modal-body">
                <p>${message}</p>
            </div>
            <div class="modal-footer">
                <button class="modal-btn cancel-btn">Cancel</button>
                <button class="modal-btn confirm-btn">Confirm</button>
            </div>
        </div>
    `;
    
    modalContainer.style.display = 'flex';
    
    // Add event listeners
    modalContainer.querySelector('.cancel-btn').addEventListener('click', () => {
        modalContainer.style.display = 'none';
    });
    
    modalContainer.querySelector('.confirm-btn').addEventListener('click', () => {
        modalContainer.style.display = 'none';
        if (typeof onConfirm === 'function') {
            onConfirm();
        }
    });
}

// Show prompt modal
function showPromptModal(title, message, onSubmit) {
    const modalContainer = document.getElementById('modal-container');
    if (!modalContainer) return;
    
    modalContainer.innerHTML = `
        <div class="modal prompt-modal">
            <div class="modal-header">
                <h3>${title}</h3>
            </div>
            <div class="modal-body">
                <p>${message}</p>
                <input type="text" class="modal-input" placeholder="Type here...">
            </div>
            <div class="modal-footer">
                <button class="modal-btn cancel-btn">Cancel</button>
                <button class="modal-btn confirm-btn">Submit</button>
            </div>
        </div>
    `;
    
    modalContainer.style.display = 'flex';
    const inputField = modalContainer.querySelector('.modal-input');
    inputField.focus();
    
    // Add event listeners
    modalContainer.querySelector('.cancel-btn').addEventListener('click', () => {
        modalContainer.style.display = 'none';
    });
    
    modalContainer.querySelector('.confirm-btn').addEventListener('click', () => {
        const value = inputField.value.trim();
        modalContainer.style.display = 'none';
        if (typeof onSubmit === 'function') {
            onSubmit(value);
        }
    });
    
    // Submit on Enter key
    inputField.addEventListener('keydown', (event) => {
        if (event.key === 'Enter') {
            const value = inputField.value.trim();
            modalContainer.style.display = 'none';
            if (typeof onSubmit === 'function') {
                onSubmit(value);
            }
        }
    });
}

// Format money value with commas and currency symbol
function formatMoney(amount) {
    return '$' + amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

// Hide the menu
function hideMenu() {
    const pageElement = document.getElementById('page');
    pageElement.classList.remove('visible');
    setTimeout(() => {
        pageElement.style.display = 'none';
    }, 300); // Match the CSS transition time
}

// Show the menu
function showMenu() {
    const pageElement = document.getElementById('page');
    pageElement.style.display = 'flex';
    pageElement.style.backgroundColor = 'rgba(17, 17, 17, 0.74)';
    
    // Small delay to trigger the animation
    setTimeout(() => {
        pageElement.classList.add('visible');
    }, 10);
}

// Update tab visibility based on config
function updateTabVisibility(tabs) {
    if (!tabs || !Array.isArray(tabs)) return;
    
    tabs.forEach(tab => {
        const tabButton = document.querySelector(`.tab-button[data-tab="${tab.id}"]`);
        if (tabButton) {
            tabButton.style.display = tab.visible ? 'flex' : 'none';
        }
    });
}