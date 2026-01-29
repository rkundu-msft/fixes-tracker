<%@ Page Language="C#" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Loop Tracker</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', Tahoma, sans-serif; background: #f5f5f5; padding: 20px; }
        .container { max-width: 1400px; margin: 0 auto; }
        h1 { color: #333; margin-bottom: 20px; }
        .tabs { display: flex; gap: 10px; margin-bottom: 20px; }
        .tab { padding: 10px 20px; background: #fff; border: none; cursor: pointer; border-radius: 5px 5px 0 0; }
        .tab.active { background: #0078d4; color: white; }
        .panel { display: none; background: #fff; padding: 20px; border-radius: 0 5px 5px 5px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .panel.active { display: block; }
        .filters { display: flex; gap: 15px; margin-bottom: 20px; flex-wrap: wrap; align-items: center; }
        .filters input, .filters select { padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px; }
        .filters input { width: 250px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
        th { background: #f8f8f8; font-weight: 600; position: sticky; top: 0; }
        tr:hover { background: #f5f9fc; }
        .status { padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: 500; }
        .status.included { background: #dff6dd; color: #107c10; }
        .status.targeted { background: #fff4ce; color: #797300; }
        .status.pending { background: #f3f2f1; color: #605e5c; }
        .status.missed { background: #fde7e9; color: #a80000; }
        .status.rolled-back { background: #e1dfdd; color: #323130; }
        .priority { font-weight: 600; }
        .priority.p1 { color: #a80000; }
        .priority.p2 { color: #ca5010; }
        .priority.p3 { color: #8764b8; }
        .train-card { background: #fff; padding: 15px; margin-bottom: 15px; border-radius: 8px; border-left: 4px solid #0078d4; }
        .train-card h3 { margin-bottom: 10px; color: #0078d4; }
        .train-dates { display: flex; gap: 20px; flex-wrap: wrap; margin-bottom: 15px; font-size: 14px; color: #666; }
        .train-dates span { background: #f3f2f1; padding: 4px 8px; border-radius: 4px; }
        .fix-count { font-size: 14px; color: #666; }
        .fix-list { margin-top: 10px; }
        .fix-item { padding: 8px 0; border-bottom: 1px solid #f3f2f1; display: flex; justify-content: space-between; }
        .add-btn { background: #0078d4; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; margin-bottom: 20px; }
        .add-btn:hover { background: #106ebe; }
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); justify-content: center; align-items: center; }
        .modal.active { display: flex; }
        .modal-content { background: white; padding: 30px; border-radius: 8px; width: 500px; max-width: 90%; }
        .modal-content h2 { margin-bottom: 20px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: 500; }
        .form-group input, .form-group select { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
        .modal-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 20px; }
        .modal-actions button { padding: 10px 20px; border-radius: 4px; cursor: pointer; }
        .btn-primary { background: #0078d4; color: white; border: none; }
        .btn-secondary { background: #f3f2f1; border: 1px solid #ddd; }
        .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 15px; margin-bottom: 20px; }
        .summary-card { background: #fff; padding: 20px; border-radius: 8px; text-align: center; }
        .summary-card .number { font-size: 32px; font-weight: 700; color: #0078d4; }
        .summary-card .label { color: #666; font-size: 14px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚂 Loop Tracker</h1>

        <div class="summary">
            <div class="summary-card">
                <div class="number" id="totalFixes">0</div>
                <div class="label">Total Fixes</div>
            </div>
            <div class="summary-card">
                <div class="number" id="includedCount">0</div>
                <div class="label">Included</div>
            </div>
            <div class="summary-card">
                <div class="number" id="targetedCount">0</div>
                <div class="label">Targeted</div>
            </div>
            <div class="summary-card">
                <div class="number" id="pendingCount">0</div>
                <div class="label">Pending</div>
            </div>
        </div>

        <div class="tabs">
            <button class="tab active" onclick="showTab('fixes')">All Fixes</button>
            <button class="tab" onclick="showTab('trains')">By Train</button>
        </div>

        <div id="fixes" class="panel active">
            <button class="add-btn" onclick="showAddModal()">+ Add Fix</button>
            <div class="filters">
                <input type="text" id="search" placeholder="Search by ID or title..." onkeyup="filterTable()">
                <select id="filterTrain" onchange="filterTable()">
                    <option value="">All Trains</option>
                </select>
                <select id="filterStatus" onchange="filterTable()">
                    <option value="">All Status</option>
                    <option value="Included">Included</option>
                    <option value="Targeted">Targeted</option>
                    <option value="Pending">Pending</option>
                    <option value="Missed">Missed</option>
                    <option value="Rolled Back">Rolled Back</option>
                </select>
                <select id="filterPriority" onchange="filterTable()">
                    <option value="">All Priority</option>
                    <option value="P1">P1</option>
                    <option value="P2">P2</option>
                    <option value="P3">P3</option>
                </select>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>Bug ID</th>
                        <th>Title</th>
                        <th>Component</th>
                        <th>Owner</th>
                        <th>Priority</th>
                        <th>Target Train</th>
                        <th>Actual Train</th>
                        <th>Status</th>
                        <th>Notes</th>
                    </tr>
                </thead>
                <tbody id="fixesTable"></tbody>
            </table>
        </div>

        <div id="trains" class="panel">
            <div id="trainsList"></div>
        </div>
    </div>

    <div class="modal" id="addModal">
        <div class="modal-content">
            <h2>Add Fix</h2>
            <div class="form-group">
                <label>Bug ID</label>
                <input type="text" id="newBugId">
            </div>
            <div class="form-group">
                <label>Title</label>
                <input type="text" id="newTitle">
            </div>
            <div class="form-group">
                <label>Component</label>
                <input type="text" id="newComponent">
            </div>
            <div class="form-group">
                <label>Owner</label>
                <input type="text" id="newOwner">
            </div>
            <div class="form-group">
                <label>Priority</label>
                <select id="newPriority">
                    <option value="P1">P1</option>
                    <option value="P2">P2</option>
                    <option value="P3">P3</option>
                </select>
            </div>
            <div class="form-group">
                <label>Target Train</label>
                <select id="newTargetTrain"></select>
            </div>
            <div class="form-group">
                <label>Status</label>
                <select id="newStatus">
                    <option value="Pending">Pending</option>
                    <option value="Targeted">Targeted</option>
                    <option value="Included">Included</option>
                </select>
            </div>
            <div class="form-group">
                <label>Notes</label>
                <input type="text" id="newNotes">
            </div>
            <div class="modal-actions">
                <button class="btn-secondary" onclick="hideModal()">Cancel</button>
                <button class="btn-primary" onclick="addFix()">Add Fix</button>
            </div>
        </div>
    </div>

    <script>
        // ============ DATA - EDIT THIS SECTION ============
        const trains = [
            { name: "T2-W-Web-25-Nov-A", codeCutoff: "Oct 31, 05:30 AM", snapDate: "Nov 03, 09:00 AM", ring2: "Nov 03, 09:00 AM", ring3: "Nov 07, 09:00 AM", general: "Nov 17, 09:00 PM" },
            { name: "T2-W-Web-26-Jan-C", codeCutoff: "Jan 16, 05:30 AM", snapDate: "Jan 19, 09:00 AM", ring2: "Jan 19, 09:00 AM", ring3: "Jan 23, 09:00 AM", general: "Feb 04, 06:00 PM" },
            { name: "T2-W-Web-26-Jan-D", codeCutoff: "Jan 23, 05:30 AM", snapDate: "Jan 26, 09:00 AM", ring2: "Jan 26, 09:00 AM", ring3: "", general: "" },
            { name: "T2-W-Web-26-Feb-A", codeCutoff: "Jan 30, 05:30 AM", snapDate: "Feb 02, 09:00 AM", ring2: "Feb 02, 09:00 AM", ring3: "Feb 06, 09:00 AM", general: "Feb 18, 06:00 PM" },
            { name: "T2-W-Web-26-Feb-B", codeCutoff: "Feb 06, 05:30 AM", snapDate: "Feb 09, 09:00 AM", ring2: "Feb 09, 09:00 AM", ring3: "", general: "" },
            { name: "T2-W-Web-26-Feb-C", codeCutoff: "Feb 13, 05:30 AM", snapDate: "Feb 16, 09:00 AM", ring2: "Feb 16, 09:00 AM", ring3: "Feb 20, 09:00 AM", general: "Mar 04, 06:00 PM" },
            { name: "T2-W-Web-26-Feb-D", codeCutoff: "Feb 20, 05:30 AM", snapDate: "Feb 23, 09:00 AM", ring2: "Feb 23, 09:00 AM", ring3: "", general: "" },
        ];

        let fixes = [
            { bugId: "12345", title: "Fix login timeout issue", component: "Auth", owner: "John", priority: "P1", targetTrain: "T2-W-Web-26-Feb-A", actualTrain: "T2-W-Web-26-Feb-A", status: "Included", notes: "Verified in Ring2" },
            { bugId: "12346", title: "API retry logic for failures", component: "API", owner: "Sarah", priority: "P1", targetTrain: "T2-W-Web-26-Feb-A", actualTrain: "T2-W-Web-26-Feb-A", status: "Included", notes: "" },
            { bugId: "12347", title: "Cache invalidation bug", component: "Cache", owner: "Mike", priority: "P2", targetTrain: "T2-W-Web-26-Feb-B", actualTrain: "T2-W-Web-26-Feb-B", status: "Included", notes: "" },
            { bugId: "12348", title: "UI alignment on dashboard", component: "UI", owner: "Lisa", priority: "P3", targetTrain: "T2-W-Web-26-Feb-B", actualTrain: "", status: "Pending", notes: "Waiting for code review" },
            { bugId: "12349", title: "Memory leak in worker", component: "Core", owner: "John", priority: "P1", targetTrain: "T2-W-Web-26-Feb-C", actualTrain: "", status: "Targeted", notes: "PR merged" },
            { bugId: "12350", title: "Search filter not working", component: "Search", owner: "Sarah", priority: "P2", targetTrain: "T2-W-Web-26-Feb-C", actualTrain: "", status: "Targeted", notes: "" },
            { bugId: "12351", title: "Export to PDF broken", component: "Export", owner: "Mike", priority: "P2", targetTrain: "T2-W-Web-26-Jan-D", actualTrain: "T2-W-Web-26-Feb-A", status: "Missed", notes: "Missed Jan-D cutoff" },
        ];
        // ============ END DATA SECTION ============

        function init() {
            populateTrainDropdowns();
            renderFixes();
            renderTrains();
            updateSummary();
        }

        function populateTrainDropdowns() {
            const filterTrain = document.getElementById('filterTrain');
            const newTargetTrain = document.getElementById('newTargetTrain');
            trains.forEach(t => {
                filterTrain.innerHTML += `<option value="${t.name}">${t.name}</option>`;
                newTargetTrain.innerHTML += `<option value="${t.name}">${t.name}</option>`;
            });
        }

        function renderFixes() {
            const tbody = document.getElementById('fixesTable');
            tbody.innerHTML = fixes.map(f => `
                <tr data-train="${f.targetTrain}" data-status="${f.status}" data-priority="${f.priority}">
                    <td><strong>${f.bugId}</strong></td>
                    <td>${f.title}</td>
                    <td>${f.component}</td>
                    <td>${f.owner}</td>
                    <td><span class="priority ${f.priority.toLowerCase()}">${f.priority}</span></td>
                    <td>${f.targetTrain}</td>
                    <td>${f.actualTrain || '-'}</td>
                    <td><span class="status ${f.status.toLowerCase().replace(' ', '-')}">${f.status}</span></td>
                    <td>${f.notes}</td>
                </tr>
            `).join('');
        }

        function renderTrains() {
            const container = document.getElementById('trainsList');
            container.innerHTML = trains.map(t => {
                const trainFixes = fixes.filter(f => f.actualTrain === t.name || (f.targetTrain === t.name && !f.actualTrain));
                const includedCount = trainFixes.filter(f => f.status === 'Included').length;
                return `
                    <div class="train-card">
                        <h3>${t.name}</h3>
                        <div class="train-dates">
                            <span>📅 Cutoff: ${t.codeCutoff}</span>
                            <span>📦 Snap: ${t.snapDate}</span>
                            ${t.ring3 ? `<span>🔵 Ring3: ${t.ring3}</span>` : ''}
                            ${t.general ? `<span>🌐 GA: ${t.general}</span>` : ''}
                        </div>
                        <div class="fix-count">${includedCount} included · ${trainFixes.length - includedCount} pending/targeted</div>
                        <div class="fix-list">
                            ${trainFixes.map(f => `
                                <div class="fix-item">
                                    <span><strong>${f.bugId}</strong> - ${f.title}</span>
                                    <span class="status ${f.status.toLowerCase().replace(' ', '-')}">${f.status}</span>
                                </div>
                            `).join('')}
                        </div>
                    </div>
                `;
            }).join('');
        }

        function updateSummary() {
            document.getElementById('totalFixes').textContent = fixes.length;
            document.getElementById('includedCount').textContent = fixes.filter(f => f.status === 'Included').length;
            document.getElementById('targetedCount').textContent = fixes.filter(f => f.status === 'Targeted').length;
            document.getElementById('pendingCount').textContent = fixes.filter(f => f.status === 'Pending').length;
        }

        function showTab(tabId) {
            document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
            document.querySelectorAll('.panel').forEach(p => p.classList.remove('active'));
            document.querySelector(`[onclick="showTab('${tabId}')"]`).classList.add('active');
            document.getElementById(tabId).classList.add('active');
        }

        function filterTable() {
            const search = document.getElementById('search').value.toLowerCase();
            const train = document.getElementById('filterTrain').value;
            const status = document.getElementById('filterStatus').value;
            const priority = document.getElementById('filterPriority').value;

            document.querySelectorAll('#fixesTable tr').forEach(row => {
                const text = row.textContent.toLowerCase();
                const matchSearch = !search || text.includes(search);
                const matchTrain = !train || row.dataset.train === train;
                const matchStatus = !status || row.dataset.status === status;
                const matchPriority = !priority || row.dataset.priority === priority;
                row.style.display = matchSearch && matchTrain && matchStatus && matchPriority ? '' : 'none';
            });
        }

        function showAddModal() { document.getElementById('addModal').classList.add('active'); }
        function hideModal() { document.getElementById('addModal').classList.remove('active'); }

        function addFix() {
            const newFix = {
                bugId: document.getElementById('newBugId').value,
                title: document.getElementById('newTitle').value,
                component: document.getElementById('newComponent').value,
                owner: document.getElementById('newOwner').value,
                priority: document.getElementById('newPriority').value,
                targetTrain: document.getElementById('newTargetTrain').value,
                actualTrain: "",
                status: document.getElementById('newStatus').value,
                notes: document.getElementById('newNotes').value
            };
            fixes.push(newFix);
            renderFixes();
            renderTrains();
            updateSummary();
            hideModal();

            // Show the data to copy
            console.log('Updated fixes array:', JSON.stringify(fixes, null, 2));
            alert('Fix added! Note: To persist changes, copy the fixes array from browser console (F12) and update tracker.html');
        }

        init();
    </script>
</body>
</html>
