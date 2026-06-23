<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TechMart Enterprise Portal</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        outfit: ['Outfit', 'sans-serif'],
                        sans: ['Inter', 'sans-serif'],
                    }
                }
            }
        }
    </script>
    <style>
        body {
            background-color: #f8fafc;
            background-image: 
                radial-gradient(at 0% 0%, rgba(124, 58, 237, 0.05) 0, transparent 50%),
                radial-gradient(at 100% 100%, rgba(99, 102, 241, 0.05) 0, transparent 50%),
                radial-gradient(at 50% 100%, rgba(236, 72, 153, 0.02) 0, transparent 40%);
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }
        
        ::-webkit-scrollbar {
            width: 6px;
            height: 6px;
        }
        ::-webkit-scrollbar-track {
            background: rgba(0, 0, 0, 0.02);
        }
        ::-webkit-scrollbar-thumb {
            background: rgba(139, 92, 246, 0.2);
            border-radius: 99px;
        }
        ::-webkit-scrollbar-thumb:hover {
            background: rgba(139, 92, 246, 0.4);
        }

        .glass-panel {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(226, 232, 240, 0.8);
            box-shadow: 0 8px 32px 0 rgba(148, 163, 184, 0.12);
        }

        .glass-card {
            background: #ffffff;
            border: 1px solid rgba(226, 232, 240, 0.8);
            box-shadow: 0 2px 4px rgba(148, 163, 184, 0.04);
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .glass-card:hover {
            background: #ffffff;
            border-color: rgba(139, 92, 246, 0.35);
            transform: translateY(-2px);
            box-shadow: 0 10px 20px -10px rgba(139, 92, 246, 0.15);
        }

        .kpi-card {
            background: #ffffff;
            border: 1px solid rgba(226, 232, 240, 0.8);
            box-shadow: 0 2px 4px rgba(148, 163, 184, 0.04);
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .kpi-card:hover {
            background: #ffffff;
            border-color: rgba(139, 92, 246, 0.35);
            transform: translateY(-2px);
            box-shadow: 0 10px 20px -10px rgba(139, 92, 246, 0.15);
        }

        .sidebar-link {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 16px;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 500;
            color: #475569;
            transition: all 0.2s ease;
            cursor: pointer;
        }
        .sidebar-link:hover {
            background: rgba(0, 0, 0, 0.04);
            color: #0f172a;
        }
        .sidebar-link.active {
            background: linear-gradient(135deg, rgba(124, 58, 237, 0.08) 0%, rgba(99, 102, 241, 0.04) 100%);
            border: 1px solid rgba(124, 58, 237, 0.25);
            color: #7c3aed;
            font-weight: 600;
            box-shadow: 0 4px 15px rgba(139, 92, 246, 0.04);
        }

        .glow-text-purple {
            color: #7c3aed;
        }

        .glow-text-emerald {
            color: #059669;
        }

        .pulse-light {
            box-shadow: 0 0 8px rgba(16, 185, 129, 0.3);
        }

        .payment-modal {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(24px);
            border: 1px solid rgba(139, 92, 246, 0.25);
            box-shadow: 0 10px 40px rgba(148, 163, 184, 0.22);
        }
    </style>
</head>
<body class="min-h-screen text-slate-800 font-sans flex relative">

<!-- Glowing decorative backdrops -->
<div class="absolute top-[10%] left-[20%] w-[35%] h-[35%] rounded-full bg-violet-500/5 blur-[120px] pointer-events-none"></div>
<div class="absolute bottom-[10%] right-[10%] w-[30%] h-[30%] rounded-full bg-indigo-500/5 blur-[120px] pointer-events-none"></div>

<!-- Sidebar Navigation -->
<aside class="flex flex-col py-6 px-5 select-none shrink-0 w-[260px] border-r border-slate-200 bg-white relative z-20 h-screen sticky top-0 overflow-y-hidden">
    <div class="flex items-center gap-3 px-3 mb-8">
        <div class="w-8 h-8 rounded-xl flex items-center justify-center text-base font-bold shadow-md" style="background: linear-gradient(135deg, #a855f7, #6366f1); color: #fff;">⚡</div>
        <span class="text-lg font-extrabold tracking-tight font-outfit bg-clip-text text-transparent bg-gradient-to-r from-violet-600 to-indigo-500">TechMart</span>
    </div>

    <nav class="space-y-6">
        <div>
            <span class="text-[10px] font-bold text-slate-400 uppercase tracking-widest px-3 block mb-3 font-outfit">Main Operations</span>
            <div class="space-y-1.5">
                <a href="#overview" id="nav-overview" class="sidebar-link active">
                    <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/></svg>
                    Overview
                </a>
                <a href="#inventory" id="nav-inventory" class="sidebar-link">
                    <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><path d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10"/></svg>
                    Product & Stock
                </a>
                <a href="#cart" id="nav-cart" class="sidebar-link">
                    <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><path d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/></svg>
                    Cart & Checkout
                </a>
                <a href="#orders" id="nav-orders" class="sidebar-link">
                    <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
                    Order Tracking
                </a>
                <a href="#metrics" id="nav-metrics" class="sidebar-link">
                    <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><path d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/></svg>
                    System Metrics
                </a>
            </div>
        </div>
    </nav>

</aside>

<!-- Main Workspace Content -->
<main class="flex-1 min-h-screen overflow-y-auto p-8 flex flex-col gap-6 relative z-10">

    <!-- Global Toast Alert Container -->
    <div id="toast-container" class="hidden w-full px-4 py-3.5 rounded-xl border font-semibold text-xs transition-all duration-300"></div>

    <!-- 1. PANEL: OVERVIEW -->
    <div id="panel-overview" class="spa-panel flex flex-col gap-6">
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold tracking-tight font-outfit text-slate-900">Operations Dashboard</h1>
                <span class="text-xs text-indigo-650 font-semibold">Real-time enterprise statistics. Auto-refreshes on tab focus.</span>
            </div>
            <div class="flex items-center gap-3">
                <span class="text-xs text-indigo-660 font-mono tracking-wider bg-indigo-50 px-3.5 py-2.5 rounded-xl border border-indigo-200/60" id="overview-clock">--:--:--</span>
                <div class="relative">
                    <input id="overview-search-input" type="text" oninput="fetchMetrics()" placeholder="Filter charts / logs..." 
                           class="text-xs pl-9 pr-4 py-2.5 rounded-xl border border-slate-200 bg-white text-slate-800 placeholder-slate-400 outline-none focus:border-violet-500/50 focus:ring-1 focus:ring-violet-500/20 transition-all w-[220px]">
                    <svg class="absolute left-3.5 top-3 w-3.5 h-3.5 text-slate-400" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
                </div>
                <button onclick="resetMetrics()" 
                        class="text-xs font-semibold px-4 py-2.5 rounded-xl border border-slate-200 bg-violet-50 hover:bg-violet-100 text-violet-700 hover:text-violet-900 transition-all duration-150">
                    Reset Cache Stats
                </button>
            </div>
        </div>

        <div class="glass-panel-glow rounded-2xl p-6 relative overflow-hidden flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div class="absolute top-0 right-0 w-[300px] h-[300px] bg-gradient-to-bl from-violet-600/5 to-transparent rounded-full pointer-events-none"></div>
            <div>
                <span class="text-[10px] font-bold text-slate-500 uppercase tracking-widest block mb-1 font-outfit">Consolidated Enterprise Revenue</span>
                <h2 id="metric-total-revenue" class="text-4xl font-extrabold tracking-tight font-outfit text-violet-600 glow-text-purple">Rs. 0.00</h2>
            </div>
            <div class="flex flex-col items-end gap-1">
                <span class="text-xs font-bold px-3 py-1 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200 tracking-wider font-outfit uppercase">System Uptime 99.99%</span>
                <span class="text-[10px] text-slate-500 font-mono">Managed by TechMartPU Database Context</span>
            </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            <div class="kpi-card rounded-2xl p-5">
                <div class="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-3 font-outfit">Catalog Products</div>
                <div class="text-3xl font-extrabold text-slate-800 font-outfit" id="metric-total-products">—</div>
                <p class="text-[11px] text-slate-500 mt-2">Active items in catalog database</p>
                <div class="mt-4 h-1 rounded-full bg-slate-100 overflow-hidden">
                    <div class="h-full rounded-full bg-gradient-to-r from-violet-500 to-indigo-500" style="width: 100%;"></div>
                </div>
            </div>
            <div class="kpi-card rounded-2xl p-5">
                <div class="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-3 font-outfit">Warehouse Inventory</div>
                <div class="text-3xl font-extrabold text-slate-800 font-outfit" id="metric-total-stock">—</div>
                <p class="text-[11px] text-slate-500 mt-2">Cached in EJB Singleton</p>
                <div class="mt-4 h-1 rounded-full bg-slate-100 overflow-hidden">
                    <div class="h-full rounded-full bg-gradient-to-r from-violet-500 to-indigo-500" style="width: 100%;"></div>
                </div>
            </div>
            <div class="kpi-card rounded-2xl p-5">
                <div class="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-3 font-outfit">Dispatched Orders</div>
                <div class="text-3xl font-extrabold text-emerald-600 glow-text-emerald font-outfit" id="metric-processed-orders">—</div>
                <p class="text-[11px] text-slate-500 mt-2">Processed asynchronously by MDB</p>
                <div class="mt-4 h-1 rounded-full bg-slate-100 overflow-hidden">
                    <div class="h-full rounded-full bg-gradient-to-r from-emerald-500 to-teal-400" style="width: 100%;"></div>
                </div>
            </div>
            <div class="kpi-card rounded-2xl p-5">
                <div class="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-3 font-outfit">Avg Payment Delay</div>
                <div class="text-3xl font-extrabold text-amber-600 font-outfit" id="metric-async-latency">0.0 ms</div>
                <p class="text-[11px] text-slate-500 mt-2">EJB async delay processing</p>
                <div class="mt-4 h-1 rounded-full bg-slate-100 overflow-hidden">
                    <div id="async-latency-bar" class="h-full rounded-full bg-gradient-to-r from-amber-500 to-orange-400" style="width: 40%;"></div>
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
            <div class="glass-panel rounded-2xl p-6 xl:col-span-2 flex flex-col border border-slate-200/85" style="min-height: 320px;">
                <div class="flex flex-col sm:flex-row justify-between sm:items-center gap-4 mb-6">
                    <div>
                        <h3 class="text-base font-bold text-slate-800 font-outfit">Revenue & Order Latency Performance</h3>
                        <p class="text-[11px] text-slate-500">Chronological summary from database context</p>
                    </div>
                    <div class="flex gap-1.5 p-1 rounded-xl bg-slate-100 border border-slate-200/60">
                        <button onclick="switchChart('revenue')" id="btn-revenue" class="chart-tab text-[10px] font-bold px-3 py-1.5 rounded-lg bg-white text-violet-750 border border-slate-200 shadow-sm transition-all">Revenue</button>
                        <button onclick="switchChart('orders')" id="btn-orders" class="chart-tab text-[10px] font-bold px-3 py-1.5 rounded-lg text-slate-500 hover:text-slate-800 transition-all">Orders</button>
                        <button onclick="switchChart('stock')" id="btn-stock" class="chart-tab text-[10px] font-bold px-3 py-1.5 rounded-lg text-slate-500 hover:text-slate-800 transition-all">Stock Levels</button>
                    </div>
                </div>
                <div class="flex-1 relative min-h-[220px]">
                    <canvas id="main-chart"></canvas>
                </div>
            </div>

            <div class="flex flex-col gap-6">
                <div class="glass-panel rounded-2xl p-6 flex-1 flex flex-col border border-slate-200/85" style="min-height: 180px;">
                    <h3 class="text-sm font-bold text-slate-800 font-outfit mb-4">Pipeline Order Status</h3>
                    <div class="flex-1 relative min-h-[140px]">
                        <canvas id="donut-chart"></canvas>
                    </div>
                </div>
                <div class="glass-panel rounded-2xl p-6 border border-slate-200/85">
                    <h3 class="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-4 font-outfit">Container Properties</h3>
                    <div class="space-y-3 text-xs">
                        <div class="flex justify-between border-b border-slate-100 pb-2">
                            <span class="text-slate-500">EJB Beans Bound</span>
                            <span class="font-bold text-slate-700">10 (Stateless/Singleton)</span>
                        </div>
                        <div class="flex justify-between border-b border-slate-100 pb-2">
                            <span class="text-slate-500">Active HTTP Sessions</span>
                            <span class="font-bold text-violet-600 font-mono" id="health-active-sessions">1</span>
                        </div>
                        <div class="flex justify-between border-b border-slate-100 pb-2">
                            <span class="text-slate-500">JMS Endpoint Context</span>
                            <span class="font-bold text-emerald-600 flex items-center gap-1">
                                <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 inline-block pulse-light animate-pulse"></span> BOUND
                            </span>
                        </div>
                        <div class="flex justify-between pb-1">
                            <span class="text-slate-500">Async Thread-Pool</span>
                            <span class="font-bold text-slate-650">Managed (Payara)</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div class="glass-panel rounded-2xl p-6 border border-slate-200/85">
                <div class="flex justify-between items-center mb-5">
                    <div>
                        <h3 class="text-sm font-bold text-slate-800 font-outfit">Recent Activity</h3>
                        <p class="text-[11px] text-slate-500">Latest checkout placements</p>
                    </div>
                    <span class="text-xs font-bold font-mono px-2.5 py-1 rounded-lg bg-indigo-50 text-indigo-700 border border-indigo-200/60" id="orders-count-badge">0</span>
                </div>
                <div id="col-checkouts" class="space-y-3 max-h-[300px] overflow-y-auto pr-1">
                    <div class="text-slate-500 text-center py-6 text-xs">Loading activity registry...</div>
                </div>
            </div>

            <div class="glass-panel rounded-2xl p-6 border border-slate-200/85">
                <div class="flex justify-between items-center mb-5">
                    <div>
                        <h3 class="text-sm font-bold text-slate-800 font-outfit">Catalog Cache Overview</h3>
                        <p class="text-[11px] text-slate-500">Products pulled from EJB Singleton CatalogCacheBean</p>
                    </div>
                    <span class="text-xs font-bold font-mono px-2.5 py-1 rounded-lg bg-indigo-50 text-indigo-700 border border-indigo-200/60" id="catalog-count-badge">0</span>
                </div>
                <div id="col-catalog" class="space-y-3 max-h-[300px] overflow-y-auto pr-1">
                    <div class="text-slate-500 text-center py-6 text-xs">Loading catalog database...</div>
                </div>
            </div>
        </div>
    </div>

    <!-- 2. PANEL: INVENTORY -->
    <div id="panel-inventory" class="spa-panel flex flex-col gap-6 hidden">
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold tracking-tight font-outfit text-slate-900">Warehouse & Inventory Control</h1>
                <span class="text-xs text-indigo-650 font-semibold">Singleton Memory cache with thread-safe Read/Write locks. Direct MySQL DB integration.</span>
            </div>
            <div class="flex flex-col sm:flex-row items-center gap-3">
                <span class="text-xs text-indigo-660 font-mono tracking-wider bg-indigo-50 px-3.5 py-2.5 rounded-xl border border-indigo-200/60" id="inventory-clock">--:--:--</span>
                <div class="flex items-center gap-2 bg-slate-100 border border-slate-200 px-4 py-2.5 rounded-xl">
                    <label class="text-[10px] font-bold text-slate-500 uppercase tracking-widest font-outfit cursor-pointer select-none" for="admin-toggle">Admin controls</label>
                    <input type="checkbox" id="admin-toggle" onchange="toggleAdminMode()" class="w-4 h-4 rounded text-violet-600 focus:ring-violet-500/20 border-slate-300 bg-white">
                </div>
                <div class="relative">
                    <input id="inventory-search-input" type="text" oninput="filterProducts()" placeholder="Search catalog by SKU/title..." 
                           class="text-xs pl-9 pr-4 py-2.5 rounded-xl border border-slate-200 bg-white text-slate-900 placeholder-slate-400 outline-none focus:border-violet-500/50 focus:ring-1 focus:ring-violet-500/20 transition-all w-[240px]">
                    <svg class="absolute left-3.5 top-3 w-3.5 h-3.5 text-slate-400" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            <div class="glass-card rounded-2xl p-5">
                <div class="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-3 font-outfit">Products Count</div>
                <div class="text-3xl font-extrabold text-slate-900 font-outfit" id="inventory-total-products">—</div>
            </div>
            <div class="glass-card rounded-2xl p-5">
                <div class="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-3 font-outfit">Total Cumulative Stock</div>
                <div class="text-3xl font-extrabold text-slate-900 font-outfit" id="inventory-total-stock">—</div>
            </div>
            <div class="glass-card rounded-2xl p-5">
                <div class="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-3 font-outfit">Low Stock Alerts</div>
                <div class="text-3xl font-extrabold text-rose-600 font-outfit" id="inventory-low-stock">—</div>
            </div>
            <div class="glass-card rounded-2xl p-5">
                <div class="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-3 font-outfit">Database Read Latency</div>
                <div class="text-3xl font-extrabold text-violet-600 glow-text-purple font-outfit" id="inventory-sync-latency">— ms</div>
            </div>
        </div>

        <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
            <div class="glass-panel rounded-2xl p-6 xl:col-span-2 flex flex-col border border-slate-200" style="min-height: 280px;">
                <h3 class="text-base font-bold text-slate-900 font-outfit mb-4">Stock levels by product SKU</h3>
                <div class="flex-1 relative min-h-[200px]">
                    <canvas id="stock-chart"></canvas>
                </div>
            </div>
            <div class="glass-panel rounded-2xl p-6 flex flex-col border border-slate-200" style="min-height: 280px;">
                <h3 class="text-sm font-bold text-slate-900 font-outfit mb-4">Warehouse status distribution</h3>
                <div class="flex-1 relative min-h-[180px]">
                    <canvas id="stock-donut"></canvas>
                </div>
            </div>
        </div>

        <div class="glass-panel rounded-2xl overflow-hidden border border-slate-200 flex-1 flex flex-col mt-4">
            <div class="flex items-center justify-between px-6 py-4 border-b border-slate-200 bg-slate-50">
                <span class="text-sm font-bold text-slate-900 font-outfit">Inventory Catalog Control</span>
                <span class="text-xs text-slate-500 font-mono">Restocking triggers cache eviction & DB persistence</span>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full text-xs text-left">
                    <thead>
                        <tr class="border-b border-slate-200 text-slate-500 uppercase tracking-wider text-[10px] font-bold bg-slate-100/50">
                            <th class="px-6 py-3.5">SKU</th>
                            <th class="px-6 py-3.5">Product Title</th>
                            <th class="px-6 py-3.5">Retail Price</th>
                            <th class="px-6 py-3.5">Stock Level</th>
                            <th class="px-6 py-3.5">Status</th>
                            <th class="px-6 py-3.5 text-right" id="inventory-table-action-header">Purchase Command</th>
                        </tr>
                    </thead>
                    <tbody id="inventory-table-body" class="divide-y divide-slate-200">
                        <tr>
                            <td colspan="6" class="px-6 py-8 text-center text-slate-500">Loading catalog database...</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <!-- Inventory Pagination Controls -->
            <div class="flex items-center justify-between px-6 py-4 border-t border-slate-200 bg-slate-50/50 hidden" id="inventory-pagination">
                <span class="text-xs text-slate-500" id="inventory-pagination-info">Showing 0-0 of 0 products</span>
                <div class="flex items-center gap-1.5">
                    <button onclick="changeInventoryPage(-1)" id="btn-inventory-prev" class="px-3 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-[10px] font-bold text-slate-600 transition-all disabled:opacity-50 disabled:pointer-events-none">Prev</button>
                    <div class="flex items-center gap-1" id="inventory-pagination-pages"></div>
                    <button onclick="changeInventoryPage(1)" id="btn-inventory-next" class="px-3 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-[10px] font-bold text-slate-600 transition-all disabled:opacity-50 disabled:pointer-events-none">Next</button>
                </div>
            </div>
        </div>
    </div>

    <!-- 3. PANEL: CART -->
    <div id="panel-cart" class="spa-panel flex flex-col gap-6 hidden">
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold tracking-tight font-outfit text-slate-900">Cart & Checkout Terminal</h1>
                <span class="text-xs text-indigo-650 font-semibold">Verify your EJB Shopping Cart details and perform simulated transaction checkouts.</span>
            </div>
            <div class="flex items-center gap-3">
                <span class="text-xs text-indigo-660 font-mono tracking-wider bg-indigo-50 px-3.5 py-2.5 rounded-xl border border-indigo-200/60" id="cart-clock">--:--:--</span>
            </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 flex-1">
            <div class="lg:col-span-2 flex flex-col gap-4">
                <div class="glass-panel rounded-2xl p-6 border border-slate-200 flex flex-col gap-4">
                    <div class="flex items-center justify-between border-b border-slate-200 pb-3">
                        <h3 class="text-base font-bold text-slate-900 font-outfit">Your Selected Components</h3>
                        <span class="text-xs font-bold text-violet-600 font-mono" id="cart-item-count">0 items</span>
                    </div>
                    <div id="cart-items-list" class="space-y-3.5 max-h-[360px] overflow-y-auto pr-1 text-xs">
                        <div class="text-slate-500 text-center py-10">Your shopping cart is currently empty.</div>
                    </div>
                    <div class="flex justify-between items-center border-t border-slate-200 pt-4">
                        <button onclick="clearCart()" class="text-xs font-semibold px-4 py-2.5 rounded-xl border border-slate-200 bg-slate-50 hover:bg-slate-100 text-slate-500 hover:text-slate-800 transition-all">
                            Clear Cart Items
                        </button>
                        <div class="text-right">
                            <span class="text-[10px] text-slate-500 font-bold uppercase tracking-wider block font-outfit">Total Subtotal</span>
                            <span class="text-xl font-bold text-violet-600 font-outfit" id="cart-total-price">Rs. 0.00</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="flex flex-col gap-4">
                <div class="glass-panel rounded-2xl p-6 border border-slate-200 flex flex-col gap-5">
                    <div class="flex items-center gap-2 border-b border-slate-200 pb-3">
                        <span class="text-base">🔒</span>
                        <h3 class="text-sm font-extrabold tracking-tight font-outfit text-slate-900">Payment Gateway</h3>
                    </div>
                    <div id="payment-error-block" class="hidden px-3.5 py-2.5 rounded-xl border border-rose-200 bg-rose-50 text-rose-700 text-xs font-semibold"></div>
                    <div class="space-y-4">
                        <div>
                            <label class="text-[10px] font-bold text-slate-500 uppercase tracking-widest block mb-1.5 font-outfit">Select Checkout Identity</label>
                            <select id="checkout-user" class="w-full text-xs px-3.5 py-2.5 rounded-xl border border-slate-200 bg-white text-slate-800 outline-none focus:border-violet-500/50">
                                <option value="3">Kamal Fernando (User ID: 3)</option>
                                <option value="2">Admin System (User ID: 2)</option>
                                <option value="1">Jane Doe (User ID: 1)</option>
                            </select>
                        </div>
                        <div>
                            <label class="text-[10px] font-bold text-slate-500 uppercase tracking-widest block mb-1.5 font-outfit">Cardholder Full Name</label>
                            <input id="payment-card-name" type="text" placeholder="Kamal Fernando" value="Kamal Fernando"
                                   class="w-full text-xs px-3.5 py-3 rounded-xl border border-slate-200 bg-slate-50 text-slate-900 outline-none focus:bg-white focus:border-violet-500/50">
                        </div>
                        <div>
                            <label class="text-[10px] font-bold text-slate-500 uppercase tracking-widest block mb-1.5 font-outfit">Card Number (16-digit dummy)</label>
                            <input id="payment-card-number" type="text" placeholder="4242 4242 4242 4242" value="4242424242424242"
                                   class="w-full text-xs px-3.5 py-3 rounded-xl border border-slate-200 bg-slate-50 text-slate-900 outline-none focus:bg-white focus:border-violet-500/50">
                        </div>
                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label class="text-[10px] font-bold text-slate-500 uppercase tracking-widest block mb-1.5 font-outfit">Expiry Date</label>
                                <input id="payment-card-expiry" type="text" placeholder="12 / 29" value="12/29"
                                       class="w-full text-xs px-3.5 py-3 rounded-xl border border-slate-200 bg-slate-50 text-slate-900 outline-none focus:bg-white focus:border-violet-500/50">
                            </div>
                            <div>
                                <label class="text-[10px] font-bold text-slate-500 uppercase tracking-widest block mb-1.5 font-outfit">CVV</label>
                                <input id="payment-card-cvv" type="text" placeholder="382" value="382"
                                       class="w-full text-xs px-3.5 py-3 rounded-xl border border-slate-200 bg-slate-50 text-slate-900 outline-none focus:bg-white focus:border-violet-500/50">
                            </div>
                        </div>
                        <div>
                            <label class="text-[10px] font-bold text-slate-500 uppercase tracking-widest block mb-1.5 font-outfit">Checkout Mode</label>
                            <select id="checkout-mode" class="w-full text-xs px-3.5 py-2.5 rounded-xl border border-slate-200 bg-white text-slate-800 outline-none focus:border-violet-500/50">
                                <option value="async">Asynchronous (Modernized JMS)</option>
                                <option value="sync">Synchronous (Legacy Monolithic)</option>
                            </select>
                        </div>
                        <button id="checkout-btn" onclick="submitPayment()" disabled 
                                class="w-full text-xs font-bold py-3.5 rounded-xl text-white glow-btn mt-2 opacity-50">
                            Confirm Payment & Checkout
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 4. PANEL: ORDERS -->
    <div id="panel-orders" class="spa-panel flex flex-col gap-6 hidden">
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold tracking-tight font-outfit text-slate-900">Order Status & JMS Notifications</h1>
                <span class="text-xs text-indigo-650 font-semibold">Asynchronous processing pipeline with Message-Driven Bean (MDB) triggers.</span>
            </div>
            <div class="flex items-center gap-3">
                <span class="text-xs text-indigo-660 font-mono tracking-wider bg-indigo-50 px-3.5 py-2.5 rounded-xl border border-indigo-200/60" id="orders-clock">--:--:--</span>
            </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 flex-1">
            <div class="lg:col-span-2 flex flex-col gap-4">
                <div class="flex justify-between items-center">
                    <h3 class="text-base font-bold text-slate-900 font-outfit">Transaction Register</h3>
                    <span class="text-xs text-indigo-650 font-semibold" id="orders-list-count-badge">0 orders total</span>
                </div>
                <div class="glass-panel rounded-2xl overflow-hidden border border-slate-200 flex-1 flex flex-col">
                    <div class="overflow-x-auto">
                        <table class="w-full text-xs text-left">
                            <thead>
                                <tr class="border-b border-slate-200 text-slate-500 uppercase tracking-wider text-[10px] font-bold bg-slate-100/50">
                                    <th class="px-6 py-4">Order ID</th>
                                    <th class="px-6 py-4">User Email</th>
                                    <th class="px-6 py-4">Amount</th>
                                    <th class="px-6 py-4">Status</th>
                                    <th class="px-6 py-4">Timestamp</th>
                                </tr>
                            </thead>
                            <tbody id="orders-list-table-body" class="divide-y divide-slate-200">
                                <tr>
                                    <td colspan="5" class="px-6 py-8 text-center text-slate-500">Loading transaction registry...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- Orders Pagination Controls -->
                    <div class="flex items-center justify-between px-6 py-4 border-t border-slate-200 bg-slate-50/50 hidden" id="orders-pagination">
                        <span class="text-xs text-slate-500" id="orders-pagination-info">Showing 0-0 of 0 orders</span>
                        <div class="flex items-center gap-1.5">
                            <button onclick="changeOrdersPage(-1)" id="btn-orders-prev" class="px-3 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-[10px] font-bold text-slate-600 transition-all disabled:opacity-50 disabled:pointer-events-none">Prev</button>
                            <div class="flex items-center gap-1" id="orders-pagination-pages"></div>
                            <button onclick="changeOrdersPage(1)" id="btn-orders-next" class="px-3 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-[10px] font-bold text-slate-600 transition-all disabled:opacity-50 disabled:pointer-events-none">Next</button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="flex flex-col gap-4">
                <div class="flex justify-between items-center">
                    <h3 class="text-base font-bold text-slate-900 font-outfit">MDB Event Stream</h3>
                    <button onclick="clearNotifications()" class="text-[10px] font-bold text-slate-500 hover:text-slate-800 transition-colors">Clear Feed</button>
                </div>
                <div class="glass-panel rounded-2xl p-5 border border-slate-200 flex flex-col gap-5 flex-1 max-h-[550px] overflow-hidden">
                    <div class="flex items-center justify-between border-b border-slate-200 pb-3">
                        <div>
                            <span class="text-[10px] text-slate-500 font-bold uppercase tracking-wider block font-outfit">JMS / Topic Listener</span>
                            <span class="text-xs text-indigo-650 font-semibold" id="notification-count">0 notifications active</span>
                        </div>
                        <span class="w-2 h-2 rounded-full bg-emerald-500 inline-block pulse-light animate-pulse"></span>
                    </div>
                    <div id="notifications-list-feed" class="space-y-3.5 overflow-y-auto pr-1 text-xs flex-1">
                        <div class="text-slate-500 text-center py-10 font-outfit">Awaiting async MDB dispatch notifications from jms/inventoryTopic...</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 5. PANEL: METRICS -->
    <div id="panel-metrics" class="spa-panel flex flex-col gap-6 hidden">
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold tracking-tight font-outfit text-slate-900">Performance Telemetry Panel</h1>
                <span class="text-xs text-indigo-650 font-semibold">Real-time JVM diagnostic stats, EJB response latencies, and transaction audits.</span>
            </div>
            <div class="flex items-center gap-3">
                <span class="text-xs text-indigo-660 font-mono tracking-wider bg-indigo-50 px-3.5 py-2.5 rounded-xl border border-indigo-200/60" id="metrics-clock">--:--:--</span>
            </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            <div class="glass-card rounded-2xl p-5">
                <div class="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-3 font-outfit">JVM Uptime</div>
                <div class="text-2xl font-extrabold text-slate-900 font-mono" id="metric-uptime">—</div>
            </div>
            <div class="glass-card rounded-2xl p-5">
                <div class="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-3 font-outfit">Heap Memory Usage</div>
                <div class="text-2xl font-extrabold text-slate-900 font-mono" id="metric-heap-memory">— MB</div>
            </div>
            <div class="glass-card rounded-2xl p-5">
                <div class="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-3 font-outfit">Active HTTP Sessions</div>
                <div class="text-2xl font-extrabold text-violet-600 glow-text-purple font-mono" id="metric-active-sessions">—</div>
            </div>
            <div class="glass-card rounded-2xl p-5">
                <div class="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-3 font-outfit">JVM Thread Count</div>
                <div class="text-2xl font-extrabold text-emerald-600 glow-text-emerald font-mono" id="metric-threads">—</div>
            </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div class="glass-panel rounded-2xl p-6 lg:col-span-2 flex flex-col border border-slate-200" style="min-height: 320px;">
                <div class="flex justify-between items-center mb-6">
                    <div>
                        <h3 class="text-base font-bold text-slate-900 font-outfit">EJB Checkout Latency History</h3>
                        <p class="text-[11px] text-slate-500">Response time comparisons (Sync vs @Asynchronous EJB thread pools)</p>
                    </div>
                </div>
                <div class="flex-1 relative min-h-[220px]">
                    <canvas id="latency-chart"></canvas>
                </div>
            </div>
            <div class="glass-panel rounded-2xl p-6 border border-slate-200 flex flex-col">
                <h3 class="text-base font-bold text-slate-900 font-outfit mb-4">EJB Component Register</h3>
                <div class="space-y-3.5 flex-1 overflow-y-auto pr-1" id="components-list">
                    <div class="text-slate-500 text-center py-10 text-xs">Loading EJB properties...</div>
                </div>
            </div>
        </div>

        <div class="flex flex-col gap-4 mt-2">
            <div class="flex justify-between items-center">
                <h3 class="text-base font-bold text-slate-900 font-outfit">Security & Audit Event Trails</h3>
                <span class="text-xs text-indigo-650 font-semibold">Auto-refreshing audit log registry</span>
            </div>
            <div class="glass-panel rounded-2xl overflow-hidden border border-slate-200">
                <div class="overflow-x-auto">
                    <table class="w-full text-xs text-left">
                        <thead>
                            <tr class="border-b border-slate-200 text-slate-500 uppercase tracking-wider text-[10px] font-bold bg-slate-100/50 sticky top-0">
                                <th class="px-6 py-3.5">Log ID</th>
                                <th class="px-6 py-3.5">Action Triggered</th>
                                <th class="px-6 py-3.5">Target entity</th>
                                <th class="px-6 py-3.5">Executor Identity</th>
                                <th class="px-6 py-3.5 text-right">Timestamp</th>
                            </tr>
                        </thead>
                        <tbody id="audit-table-body" class="divide-y divide-slate-200">
                            <tr>
                                <td colspan="5" class="px-6 py-8 text-center text-slate-500">Loading audit history logs...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <!-- Audit Pagination Controls -->
                <div class="flex items-center justify-between px-6 py-4 border-t border-slate-200 bg-slate-50/50 hidden" id="audit-pagination">
                    <span class="text-xs text-slate-500" id="audit-pagination-info">Showing 0-0 of 0 logs</span>
                    <div class="flex items-center gap-1.5">
                        <button onclick="changeAuditPage(-1)" id="btn-audit-prev" class="px-3 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-[10px] font-bold text-slate-600 transition-all disabled:opacity-50 disabled:pointer-events-none">Prev</button>
                        <div class="flex items-center gap-1" id="audit-pagination-pages"></div>
                        <button onclick="changeAuditPage(1)" id="btn-audit-next" class="px-3 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-[10px] font-bold text-slate-600 transition-all disabled:opacity-50 disabled:pointer-events-none">Next</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

</main>

<!-- Restock Dialog Modal -->
<div id="restock-modal-backdrop" class="fixed inset-0 bg-black/60 backdrop-blur-md z-50 flex items-center justify-center hidden transition-opacity duration-300 opacity-0">
    <div class="w-full max-w-sm payment-modal rounded-2xl p-6 relative">
        <button onclick="closeRestockModal()" class="absolute top-4 right-4 text-slate-500 hover:text-slate-800 text-lg font-bold">×</button>
        <div class="flex items-center gap-2 mb-6 border-b border-slate-200 pb-3">
            <span class="text-lg">📦</span>
            <h3 class="text-base font-extrabold tracking-tight font-outfit text-slate-900" id="modal-title">Restock Product</h3>
        </div>
        <div class="space-y-4">
            <input type="hidden" id="restock-product-id">
            <div>
                <label class="text-[10px] font-bold text-slate-500 uppercase tracking-widest block mb-2 font-outfit">Product SKU / Title</label>
                <p id="restock-product-display" class="text-sm font-semibold text-violet-600 font-outfit"></p>
            </div>
            <div>
                <label class="text-[10px] font-bold text-slate-500 uppercase tracking-widest block mb-2 font-outfit">Quantity to Add</label>
                <input id="restock-qty" type="number" value="50" min="1" max="1000" 
                       class="w-full text-xs px-3.5 py-3 rounded-xl border border-slate-200 bg-slate-50 text-slate-900 outline-none focus:border-violet-500/50">
            </div>
            <button onclick="submitRestock()" 
                    class="w-full text-xs font-bold py-3.5 rounded-xl text-white glow-btn mt-2">
                Commit Restock
            </button>
        </div>
    </div>
</div>

<!-- PAYMENT LOADING OVERLAY -->
<div id="loading-overlay" class="fixed inset-0 bg-white/90 backdrop-blur-sm z-50 flex flex-col items-center justify-center hidden">
    <div class="w-10 h-10 border-2 border-violet-600 border-t-transparent rounded-full animate-spin mb-4"></div>
    <p class="text-sm font-semibold text-slate-800 font-outfit" id="loading-message">Contacting banking network...</p>
    <p class="text-[10px] text-slate-500 font-mono mt-2" id="loading-sub">Awaiting async payment resolution...</p>
</div>

<!-- SPA Routing and Controller Script -->
<script>
    let pollingInterval = null;
    let mainChart = null;
    let donutChart = null;
    let stockChart = null;
    let stockDonut = null;
    let latencyChart = null;
    let currentOverviewTab = 'revenue';
    let latestOverviewData = null;
    
    let productsList = [];
    let ordersList = [];
    let auditsList = [];

    let ordersCurrentPage = 1;
    const ordersPageSize = 10;
    
    let inventoryCurrentPage = 1;
    const inventoryPageSize = 10;
    
    let auditCurrentPage = 1;
    const auditPageSize = 10;

    let adminMode = false;
    
    let notifiedOrders = new Set();
    let notificationsCount = 0;
    
    let latencyHistory = { sync: [], async: [], labels: [] };
    let maxDataPoints = 12;

    // Clock
    function initClock() {
        setInterval(() => {
            const timeStr = new Date().toLocaleTimeString('en-US', {
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: false
            });
            document.querySelectorAll('[id$="-clock"]').forEach(el => {
                el.textContent = timeStr;
            });
        }, 1000);
    }

    // Sidebar active state
    function updateSidebarActive(tab) {
        document.querySelectorAll('.sidebar-link').forEach(link => {
            link.classList.remove('active');
        });
        const activeLink = document.getElementById('nav-' + tab);
        if (activeLink) {
            activeLink.classList.add('active');
        }
    }

    // Dynamic Navigation Routing
    function handleNavigation() {
        const hash = window.location.hash || '#overview';
        const tab = hash.substring(1);
        
        // Hide all panels
        document.querySelectorAll('.spa-panel').forEach(panel => {
            panel.classList.add('hidden');
        });
        
        // Show active panel
        const activePanel = document.getElementById('panel-' + tab);
        if (activePanel) {
            activePanel.classList.remove('hidden');
        }
        
        updateSidebarActive(tab);
        
        // Clear background loops
        if (pollingInterval) {
            clearInterval(pollingInterval);
            pollingInterval = null;
        }
        
        // Switch tab context operations
        if (tab === 'overview') {
            fetchMetrics();
            pollingInterval = setInterval(fetchMetrics, 2000);
        } else if (tab === 'inventory') {
            loadCatalog();
            pollingInterval = setInterval(loadCatalog, 2000);
        } else if (tab === 'cart') {
            loadCart();
            pollingInterval = setInterval(loadCart, 3000);
        } else if (tab === 'orders') {
            loadOrders();
            pollingInterval = setInterval(loadOrders, 2000);
        } else if (tab === 'metrics') {
            fetchTelemetry();
            fetchAudits();
            pollingInterval = setInterval(() => {
                fetchTelemetry();
                fetchAudits();
            }, 2500);
        }
    }

    // ==========================================
    // TAB: OVERVIEW CONTROLLERS
    // ==========================================
    function buildMainChart(data) {
        const ctx = document.getElementById('main-chart').getContext('2d');
        const orders = [...(data.recentOrders || [])].reverse();
        const labels = orders.map(o => '#' + o.id);
        
        let values = [];
        let labelStr = '';
        let borderCol = '#a855f7';
        let bgGradStop = 'rgba(168, 85, 247, 0.15)';
        
        if (currentOverviewTab === 'revenue') {
            values = orders.map(o => o.totalAmount || 0);
            labelStr = 'Order Amount (Rs.)';
            borderCol = '#a855f7';
            bgGradStop = 'rgba(168, 85, 247, 0.15)';
        } else if (currentOverviewTab === 'orders') {
            values = orders.map((o, idx) => idx + 1);
            labelStr = 'Cumulative Count';
            borderCol = '#3b82f6';
            bgGradStop = 'rgba(59, 130, 246, 0.15)';
        } else {
            values = data.catalog.map(p => data.stocks[p.id] || 0);
            labels.length = 0;
            data.catalog.forEach(p => labels.push(p.title.substring(0, 12) + '...'));
            labelStr = 'Stock Level';
            borderCol = '#eab308';
            bgGradStop = 'rgba(234, 179, 8, 0.15)';
        }

        const grad = ctx.createLinearGradient(0, 0, 0, 240);
        grad.addColorStop(0, bgGradStop);
        grad.addColorStop(1, 'rgba(248, 250, 252, 0)');

        if (mainChart) {
            mainChart.data.labels = labels.length ? labels : ['No orders'];
            mainChart.data.datasets[0].label = labelStr;
            mainChart.data.datasets[0].data = values.length ? values : [0];
            mainChart.data.datasets[0].borderColor = borderCol;
            mainChart.data.datasets[0].backgroundColor = grad;
            mainChart.data.datasets[0].pointBorderColor = borderCol;
            mainChart.update('none');
        } else {
            mainChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels.length ? labels : ['No orders'],
                    datasets: [{
                        label: labelStr,
                        data: values.length ? values : [0],
                        borderColor: borderCol,
                        backgroundColor: grad,
                        borderWidth: 2,
                        pointRadius: 4,
                        pointHoverRadius: 6,
                        pointBackgroundColor: '#ffffff',
                        pointBorderColor: borderCol,
                        pointBorderWidth: 2,
                        fill: true,
                        tension: 0.35,
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            backgroundColor: '#ffffff',
                            titleColor: '#7c3aed',
                            bodyColor: '#1e293b',
                            padding: 12,
                            cornerRadius: 12,
                            borderColor: 'rgba(226, 232, 240, 0.9)',
                            borderWidth: 1,
                            callbacks: {
                                label: ctx => currentOverviewTab === 'revenue' 
                                    ? 'Rs. ' + ctx.parsed.y.toLocaleString('en-US', {minimumFractionDigits: 2})
                                    : ctx.parsed.y
                            }
                        }
                    },
                    scales: {
                        x: { grid: { color: 'rgba(0, 0, 0, 0.04)' }, ticks: { color: '#475569', font: { size: 10 } } },
                        y: { grid: { color: 'rgba(0, 0, 0, 0.04)' }, ticks: { color: '#475569', font: { size: 10 } } }
                    }
                }
            });
        }
    }
 
    function buildDonutChart(data) {
        const ctx = document.getElementById('donut-chart').getContext('2d');
        const orders = data.recentOrders || [];
        
        let processed = data.processedOrders || 0;
        let failed = data.failedOrders || 0;
        let pending = orders.filter(o => o.status === 'PENDING' || o.status === 'PENDING_PAYMENT').length;
        
        orders.forEach(o => {
            if (o.status === 'FAILED_PAYMENT') failed++;
        });
 
        if (donutChart) {
            donutChart.data.datasets[0].data = [processed, pending, failed];
            donutChart.update('none');
        } else {
            donutChart = new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: ['Processed/Success', 'Pending Payment', 'Failed/Declined'],
                    datasets: [{
                        data: [processed, pending, failed],
                        backgroundColor: ['#10b981', '#6366f1', '#ef4444'],
                        borderWidth: 0,
                        hoverOffset: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: '75%',
                    plugins: {
                        legend: {
                            position: 'right',
                            labels: { color: '#475569', boxWidth: 10, font: { size: 10, family: 'Inter' } }
                        }
                    }
                }
            });
        }
    }
 
    function switchChart(tab) {
        currentOverviewTab = tab;
        document.querySelectorAll('.chart-tab').forEach(b => {
            b.className = 'chart-tab text-[10px] font-bold px-3 py-1.5 rounded-lg text-slate-500 hover:text-slate-800 transition-all';
        });
        const activeBtn = document.getElementById('btn-' + tab);
        if (activeBtn) {
            activeBtn.className = 'chart-tab text-[10px] font-bold px-3 py-1.5 rounded-lg bg-white text-violet-750 border border-slate-200 shadow-sm transition-all';
        }
        if (latestOverviewData) buildMainChart(latestOverviewData);
    }

    async function fetchMetrics() {
        try {
            const queryInput = document.getElementById('overview-search-input');
            const query = queryInput ? queryInput.value.toLowerCase() : '';
            
            const res = await fetch('<%= request.getContextPath() %>/dashboard?format=json');
            const data = await res.json();
            latestOverviewData = data;

            document.getElementById('metric-total-products').textContent = data.totalProducts;
            document.getElementById('metric-total-stock').textContent = data.totalStock;
            document.getElementById('metric-processed-orders').textContent = data.processedOrders;
            document.getElementById('metric-async-latency').textContent = data.asyncLatency.toFixed(1) + ' ms';
            
            const delayPercent = Math.min(100, Math.max(10, (data.asyncLatency / 1000) * 100));
            document.getElementById('async-latency-bar').style.width = delayPercent + '%';

            document.getElementById('metric-total-revenue').textContent = 'Rs. ' + data.totalRevenue.toLocaleString('en-US', {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            });

            document.getElementById('health-active-sessions').textContent = data.activeSessions || 1;

            buildMainChart(data);
            buildDonutChart(data);

            const checkoutsCol = document.getElementById('col-checkouts');
            const filteredOrders = (data.recentOrders || []).filter(o => 
                o.userEmail.toLowerCase().includes(query) || o.status.toLowerCase().includes(query) || ('#' + o.id).includes(query)
            );
            document.getElementById('orders-count-badge').textContent = filteredOrders.length;

            if (filteredOrders.length === 0) {
                checkoutsCol.innerHTML = `<div class="text-xs text-slate-500 text-center py-6">No recent transactions matches</div>`;
            } else {
                let html = '';
                filteredOrders.forEach(o => {
                    let badgeColor = 'bg-slate-100 text-slate-650 border-slate-200';
                    if (o.status === 'PROCESSED' || o.status === 'PAYMENT_SUCCESS') badgeColor = 'bg-emerald-50 text-emerald-700 border-emerald-250';
                    else if (o.status.includes('FAILED')) badgeColor = 'bg-rose-50 text-rose-700 border-rose-250';

                    html += `
                        <div class="flex justify-between items-center p-3 rounded-xl border border-slate-200/80 bg-slate-50/50 hover:bg-slate-100/60 transition-all duration-150">
                            <div>
                                <div class="text-xs font-bold text-slate-800">Order #${o.id}</div>
                                <div class="text-[10px] text-slate-500 mt-0.5">${o.userEmail}</div>
                            </div>
                            <div class="text-right">
                                <div class="text-xs font-bold text-slate-700">Rs. ${o.totalAmount.toLocaleString('en-US', {minimumFractionDigits: 2})}</div>
                                <span class="text-[9px] font-semibold px-2 py-0.5 rounded-full border ${badgeColor} inline-block mt-1 font-mono">${o.status}</span>
                            </div>
                        </div>
                    `;
                });
                checkoutsCol.innerHTML = html;
            }

            const catalogCol = document.getElementById('col-catalog');
            const filteredCatalog = (data.catalog || []).filter(p => 
                p.title.toLowerCase().includes(query) || p.sku.toLowerCase().includes(query)
            );
            document.getElementById('catalog-count-badge').textContent = filteredCatalog.length;

            if (filteredCatalog.length === 0) {
                catalogCol.innerHTML = `<div class="text-xs text-slate-500 text-center py-6">No catalog products match</div>`;
            } else {
                let html = '';
                filteredCatalog.forEach(p => {
                    const stock = data.stocks && data.stocks[p.id] !== undefined ? data.stocks[p.id] : 0;
                    let stockBadge = 'text-emerald-700 bg-emerald-50 border border-emerald-250';
                    if (stock <= 0) stockBadge = 'text-rose-700 bg-rose-50 border border-rose-250';
                    else if (stock < 20) stockBadge = 'text-amber-700 bg-amber-50 border border-amber-250';

                    html += `
                        <div class="flex justify-between items-center p-3 rounded-xl border border-slate-200/80 bg-slate-50/50 hover:bg-slate-100/60 transition-all duration-150 text-xs">
                            <div>
                                <div class="font-bold text-slate-800">${p.title}</div>
                                <div class="text-[10px] text-indigo-600 mt-0.5 font-mono">${p.sku}</div>
                            </div>
                            <div class="text-right">
                                <div class="font-bold text-slate-700">Rs. ${p.price.toLocaleString('en-US', {minimumFractionDigits: 2})}</div>
                                <span class="text-[9px] font-semibold px-2 py-0.5 rounded-full inline-block mt-1 font-mono ${stockBadge}">${stock} Units</span>
                            </div>
                        </div>
                    `;
                });
                catalogCol.innerHTML = html;
            }
        } catch (e) {
            console.error('Error fetching metrics', e);
        }
    }

    async function resetMetrics() {
        if (!confirm("Are you sure you want to reset the EJB cache metrics registry?")) return;
        try {
            await fetch('<%= request.getContextPath() %>/dashboard?action=reset&format=json');
            fetchMetrics();
        } catch (e) {
            console.error(e);
        }
    }

    // ==========================================
    // TAB: INVENTORY CONTROLLERS
    // ==========================================
    function buildInventoryCharts(products) {
        const barCtx = document.getElementById('stock-chart').getContext('2d');
        const barLabels = products.map(p => p.sku);
        const barData = products.map(p => p.stock);

        if (stockChart) {
            stockChart.data.labels = barLabels.length ? barLabels : ['None'];
            stockChart.data.datasets[0].data = barData.length ? barData : [0];
            stockChart.data.datasets[0].backgroundColor = barData.map(v => v < 20 ? 'rgba(239, 68, 68, 0.75)' : 'rgba(16, 185, 129, 0.75)');
            stockChart.update('none');
        } else {
            stockChart = new Chart(barCtx, {
                type: 'bar',
                data: {
                    labels: barLabels.length ? barLabels : ['None'],
                    datasets: [{
                        data: barData.length ? barData : [0],
                        backgroundColor: barData.map(v => v < 20 ? 'rgba(239, 68, 68, 0.75)' : 'rgba(16, 185, 129, 0.75)'),
                        borderRadius: 6
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        x: { ticks: { color: '#475569', font: { size: 9 } }, grid: { display: false } },
                        y: { ticks: { color: '#475569', font: { size: 9 } }, grid: { color: 'rgba(0,0,0,0.04)' } }
                    }
                }
            });
        }

        const donutCtx = document.getElementById('stock-donut').getContext('2d');
        const inStock = products.filter(p => p.stock >= 20).length;
        const lowStock = products.filter(p => p.stock > 0 && p.stock < 20).length;
        const outOfStock = products.filter(p => p.stock <= 0).length;

        if (stockDonut) {
            stockDonut.data.datasets[0].data = [inStock, lowStock, outOfStock];
            stockDonut.update('none');
        } else {
            stockDonut = new Chart(donutCtx, {
                type: 'doughnut',
                data: {
                    labels: ['In Stock', 'Low Stock', 'Out of Stock'],
                    datasets: [{
                        data: [inStock, lowStock, outOfStock],
                        backgroundColor: ['#10b981', '#f59e0b', '#ef4444'],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: '70%',
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: { color: '#475569', font: { size: 9 }, boxWidth: 8 }
                        }
                    }
                }
            });
        }
    }

    async function loadCatalog() {
        try {
            const res = await fetch('<%= request.getContextPath() %>/inventory?format=json');
            const data = await res.json();
            productsList = data.products || [];

            document.getElementById('inventory-total-products').textContent = data.totalProducts;
            document.getElementById('inventory-total-stock').textContent = data.totalStock;
            document.getElementById('inventory-low-stock').textContent = data.lowStockCount;
            document.getElementById('inventory-sync-latency').textContent = data.syncLatency.toFixed(1) + ' ms';

            buildInventoryCharts(productsList);
            renderInventoryTable();
        } catch (e) {
            console.error(e);
        }
    }

    function toggleAdminMode() {
        adminMode = document.getElementById('admin-toggle').checked;
        const header = document.getElementById('inventory-table-action-header');
        if (header) {
            header.textContent = adminMode ? 'Restock Command' : 'Purchase Command';
        }
        renderInventoryTable();
    }

    async function addToCart(id) {
        const qtyInput = document.getElementById('qty-' + id);
        const qty = qtyInput ? qtyInput.value : 1;
        try {
            const res = await fetch(`<%= request.getContextPath() %>/cart?action=add&productId=${id}&quantity=${qty}`, {
                method: 'POST'
            });
            const data = await res.json();
            
            if (data.status === 'success') {
                showToast(`Successfully added item to your Stateful cart! Total items: ${data.totalQuantity}`, 'success');
                loadCatalog();
            } else {
                showToast(`Failed to add to cart: ${data.message}`, 'error');
            }
        } catch (e) {
            showToast('Connection error adding item to cart', 'error');
        }
    }

    function getFilteredProducts() {
        const queryInput = document.getElementById('inventory-search-input');
        const query = queryInput ? queryInput.value.toLowerCase() : '';
        return productsList.filter(p => 
            p.title.toLowerCase().includes(query) || 
            p.sku.toLowerCase().includes(query)
        );
    }

    function renderInventoryTable() {
        const tbody = document.getElementById('inventory-table-body');
        const filtered = getFilteredProducts();
        
        if (filtered.length === 0) {
            tbody.innerHTML = `<tr><td colspan="6" class="px-6 py-8 text-center text-slate-500">No matching products found.</td></tr>`;
            const pag = document.getElementById('inventory-pagination');
            if (pag) pag.classList.add('hidden');
            return;
        }
        
        const pag = document.getElementById('inventory-pagination');
        if (pag) pag.classList.remove('hidden');
        
        const totalItems = filtered.length;
        const totalPages = Math.ceil(totalItems / inventoryPageSize);
        if (inventoryCurrentPage > totalPages) inventoryCurrentPage = Math.max(1, totalPages);
        
        const startIndex = (inventoryCurrentPage - 1) * inventoryPageSize;
        const endIndex = Math.min(startIndex + inventoryPageSize, totalItems);
        
        const pageItems = filtered.slice(startIndex, endIndex);
        
        let html = '';
        pageItems.forEach(p => {
            let statusBadge = 'bg-emerald-50 text-emerald-700 border-emerald-250';
            if (p.stock <= 0) statusBadge = 'bg-rose-50 text-rose-700 border-rose-250';
            else if (p.stock < 20) statusBadge = 'bg-amber-50 text-amber-700 border-amber-250';

            let actionHtml = '';
            if (adminMode) {
                actionHtml = `
                    <button onclick="openRestockModal(${p.id}, '${p.sku}', '${p.title}')"
                            class="text-[10px] font-bold px-3 py-1.5 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-700 hover:text-slate-900 border border-slate-300 transition-all duration-150">
                        Restock
                    </button>
                `;
            } else {
                actionHtml = `
                    <div class="flex items-center justify-end gap-2">
                        <input type="number" id="qty-${p.id}" value="1" min="1" max="10" 
                               class="w-12 text-center text-xs py-1 rounded bg-white border border-slate-200 text-slate-900 outline-none focus:border-violet-500/50">
                        <button onclick="addToCart(${p.id})" 
                                class="text-[10px] font-bold px-3 py-1.5 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-700 hover:text-slate-900 border border-slate-300 transition-all duration-150">
                            + Cart
                        </button>
                    </div>
                `;
            }

            html += `
                <tr class="hover:bg-slate-50 transition-all">
                    <td class="px-6 py-3.5 font-bold text-indigo-650 font-mono">${p.sku}</td>
                    <td class="px-6 py-3.5 font-semibold text-slate-800">${p.title}</td>
                    <td class="px-6 py-3.5 font-bold text-slate-900">Rs. ${p.price.toLocaleString('en-US', {minimumFractionDigits: 2})}</td>
                    <td class="px-6 py-3.5 font-mono text-slate-850">${p.stock}</td>
                    <td class="px-6 py-3.5">
                        <span class="text-[9px] font-bold px-2 py-0.5 rounded-full border ${statusBadge}">${p.stockStatus}</span>
                    </td>
                    <td class="px-6 py-3.5 text-right">
                        ${actionHtml}
                    </td>
                </tr>
            `;
        });
        
        tbody.innerHTML = html;
        
        // Update pagination UI
        const infoEl = document.getElementById('inventory-pagination-info');
        if (infoEl) infoEl.textContent = `Showing ${totalItems === 0 ? 0 : startIndex + 1}-${endIndex} of ${totalItems} products`;
        
        const btnPrev = document.getElementById('btn-inventory-prev');
        if (btnPrev) btnPrev.disabled = (inventoryCurrentPage === 1);
        
        const btnNext = document.getElementById('btn-inventory-next');
        if (btnNext) btnNext.disabled = (inventoryCurrentPage === totalPages || totalPages === 0);
        
        const pagesContainer = document.getElementById('inventory-pagination-pages');
        if (pagesContainer) {
            pagesContainer.innerHTML = '';
            let startPage = Math.max(1, inventoryCurrentPage - 2);
            let endPage = Math.min(totalPages, startPage + 4);
            if (endPage - startPage < 4) {
                startPage = Math.max(1, endPage - 4);
            }
            
            for (let i = startPage; i <= endPage; i++) {
                const activeClass = i === inventoryCurrentPage 
                    ? 'bg-violet-600 text-white border-violet-600' 
                    : 'bg-white hover:bg-slate-50 text-slate-600 border-slate-200';
                pagesContainer.innerHTML += `
                    <button onclick="goInventoryPage(${i})" class="w-7 h-7 flex items-center justify-center rounded-lg border text-[10px] font-bold transition-all ${activeClass}">${i}</button>
                `;
            }
        }
    }

    function goInventoryPage(page) {
        inventoryCurrentPage = page;
        renderInventoryTable();
    }
    
    function changeInventoryPage(dir) {
        inventoryCurrentPage += dir;
        renderInventoryTable();
    }

    function filterProducts() {
        inventoryCurrentPage = 1;
        renderInventoryTable();
    }

    function openRestockModal(id, sku, title) {
        document.getElementById('restock-product-id').value = id;
        document.getElementById('restock-product-display').textContent = sku + ' — ' + title;
        document.getElementById('restock-qty').value = 50;

        const backdrop = document.getElementById('restock-modal-backdrop');
        backdrop.classList.remove('hidden');
        setTimeout(() => {
            backdrop.classList.remove('opacity-0');
        }, 10);
    }

    function closeRestockModal() {
        const backdrop = document.getElementById('restock-modal-backdrop');
        backdrop.classList.add('opacity-0');
        setTimeout(() => {
            backdrop.classList.add('hidden');
        }, 300);
    }

    async function submitRestock() {
        const id = document.getElementById('restock-product-id').value;
        const qty = document.getElementById('restock-qty').value;

        try {
            const res = await fetch(`<%= request.getContextPath() %>/inventory?action=restock&productId=${id}&quantity=${qty}`, {
                method: 'POST'
            });
            const data = await res.json();
            closeRestockModal();

            if (data.status === 'success') {
                showToast(`Restock successful: Added ${qty} units to inventory! Cache updated.`, 'success');
                loadCatalog();
            } else {
                showToast(`Failed to update stock: ${data.message}`, 'error');
            }
        } catch (e) {
            closeRestockModal();
            showToast('Connection error restocking item', 'error');
        }
    }

    // ==========================================
    // TAB: CART CONTROLLERS
    // ==========================================
    async function loadCart() {
        try {
            const res = await fetch('<%= request.getContextPath() %>/cart?action=get');
            const data = await res.json();
            
            const list = document.getElementById('cart-items-list');
            
            const items = data.items || [];
            let totalQty = 0;
            let totalPrice = 0;

            if (items.length === 0) {
                list.innerHTML = `<div class="text-slate-500 text-center py-10">Your stateful shopping cart is empty</div>`;
                document.getElementById('cart-item-count').textContent = '0 items';
                document.getElementById('cart-total-price').textContent = 'Rs. 0.00';
                document.getElementById('checkout-btn').disabled = true;
                document.getElementById('checkout-btn').classList.add('opacity-50');
                return;
            }

            document.getElementById('checkout-btn').disabled = false;
            document.getElementById('checkout-btn').classList.remove('opacity-50');

            let html = '';
            items.forEach(item => {
                totalQty += item.quantity;
                totalPrice += (item.price * item.quantity);

                html += `
                    <div class="flex justify-between items-center p-3 rounded-xl border border-slate-200 bg-white shadow-sm">
                        <div class="max-w-[70%]">
                            <div class="font-bold text-slate-800 truncate">${item.title}</div>
                            <div class="text-[10px] text-slate-500 mt-0.5">Rs. ${item.price.toLocaleString('en-US', {minimumFractionDigits: 2})} x ${item.quantity}</div>
                        </div>
                        <div class="flex items-center gap-2">
                            <span class="font-bold text-slate-950">Rs. ${(item.price * item.quantity).toLocaleString('en-US', {minimumFractionDigits: 2})}</span>
                            <button onclick="removeFromCart(${item.productId})" class="text-rose-600 font-bold px-1.5 hover:text-rose-800 text-sm">×</button>
                        </div>
                    </div>
                `;
            });
            list.innerHTML = html;

            document.getElementById('cart-item-count').textContent = `${totalQty} items`;
            document.getElementById('cart-total-price').textContent = 'Rs. ' + totalPrice.toLocaleString('en-US', {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            });
        } catch (e) {
            console.error('Cart load failed', e);
        }
    }

    async function removeFromCart(id) {
        try {
            await fetch(`<%= request.getContextPath() %>/cart?action=remove&productId=${id}`);
            showToast('Item removed from cart', 'success');
            loadCart();
        } catch (e) {
            showToast('Failed to remove item', 'error');
        }
    }

    async function clearCart() {
        try {
            await fetch(`<%= request.getContextPath() %>/cart?action=clear`);
            showToast('Cart cleared', 'success');
            loadCart();
        } catch (e) {
            console.error(e);
        }
    }

    async function submitPayment() {
        const userId = document.getElementById('checkout-user').value;
        const name = document.getElementById('payment-card-name').value;
        const card = document.getElementById('payment-card-number').value;
        const expiry = document.getElementById('payment-card-expiry').value;
        const cvv = document.getElementById('payment-card-cvv').value;
        const mode = document.getElementById('checkout-mode').value;

        const overlay = document.getElementById('loading-overlay');
        const overlayMsg = document.getElementById('loading-message');
        const overlaySub = document.getElementById('loading-sub');
        overlay.classList.remove('hidden');
        
        if (mode === 'sync') {
            overlayMsg.textContent = "Authorizing Card & Processing Order Synchronously...";
            overlaySub.textContent = "Legacy blocking execution thread (Simulated Gateway)";
        } else {
            overlayMsg.textContent = "Authorizing Card with EJB Thread Pool...";
            overlaySub.textContent = "Awaiting future resolution (400ms timeout threshold)";
        }

        try {
            const checkoutUrl = `<%= request.getContextPath() %>/cart?action=checkout&userId=${userId}&cardNumber=${encodeURIComponent(card)}&expiry=${encodeURIComponent(expiry)}&cvv=${encodeURIComponent(cvv)}&mode=${mode}`;
            
            const res = await fetch(checkoutUrl);
            const data = await res.json();
            
            overlay.classList.add('hidden');
            document.getElementById('payment-error-block').classList.add('hidden');

            if (res.status === 200 && data.status === 'success') {
                showToast(`Payment Authorized! Order #${data.orderId} created successfully in ${data.durationMs}ms. Transaction: ${data.transactionId.substring(0, 8)}...`, 'success');
                loadCart();
            } else if (res.status === 202 && data.status === 'pending') {
                showToast(`Background Processing Activated: Payment is taking longer than 400ms. Order #${data.orderId} will finalize in the background!`, 'warning');
                loadCart();
            } else {
                document.getElementById('payment-error-block').textContent = data.message || "Payment Declined.";
                document.getElementById('payment-error-block').classList.remove('hidden');
            }
        } catch (e) {
            overlay.classList.add('hidden');
            document.getElementById('payment-error-block').textContent = "Payment gateway error: " + e.message;
            document.getElementById('payment-error-block').classList.remove('hidden');
        }
    }

    // ==========================================
    // TAB: ORDERS EVENT STREAM CONTROLLERS
    // ==========================================
    function clearNotifications() {
        document.getElementById('notifications-list-feed').innerHTML = 
            `<div class="text-slate-500 text-center py-10 font-outfit">Feed cleared. Awaiting new events...</div>`;
        document.getElementById('notification-count').textContent = '0 notifications active';
        notificationsCount = 0;
    }

    async function loadOrders() {
        try {
            const res = await fetch('<%= request.getContextPath() %>/orders?format=json');
            const data = await res.json();
            ordersList = data.orders || [];

            const feed = document.getElementById('notifications-list-feed');
            let newNotifications = '';

            ordersList.forEach(o => {
                if (!notifiedOrders.has(o.id)) {
                    notifiedOrders.add(o.id);
                    if (o.status === 'PROCESSED' || o.status === 'PAYMENT_SUCCESS') {
                        notificationsCount++;
                        newNotifications = `
                            <div class="p-3 rounded-xl border border-emerald-200 bg-emerald-50 text-xs shadow-sm">
                                <div class="flex justify-between items-center mb-1.5">
                                    <span class="font-bold text-emerald-700">🔔 Order Processed</span>
                                    <span class="text-[9px] text-slate-500 font-mono">Topic Event Received</span>
                                </div>
                                <p class="text-slate-700">Order <strong>#${o.id}</strong> has been successfully processed by <strong>SupplyChainMDB</strong>.</p>
                                <p class="text-[9px] text-indigo-600 mt-1 font-mono">Notification email triggered to ${o.userEmail}</p>
                            </div>
                        ` + newNotifications;
                    } else if (o.status.includes('FAILED')) {
                        notificationsCount++;
                        newNotifications = `
                            <div class="p-3 rounded-xl border border-rose-200 bg-rose-50 text-xs shadow-sm">
                                <div class="flex justify-between items-center mb-1.5">
                                    <span class="font-bold text-rose-700">🚨 Payment Declined</span>
                                    <span class="text-[9px] text-slate-500 font-mono">Transaction Failed</span>
                                </div>
                                <p class="text-slate-700">Order <strong>#${o.id}</strong> payment authorization failed. Insufficient funds or invalid CVV.</p>
                            </div>
                        ` + newNotifications;
                    }
                }
            });

            if (newNotifications) {
                if (feed.innerHTML.includes('Awaiting async MDB')) {
                    feed.innerHTML = '';
                }
                feed.innerHTML = newNotifications + feed.innerHTML;
                document.getElementById('notification-count').textContent = `${notificationsCount} notifications active`;
            }

            renderOrdersTable();
        } catch (e) {
            console.error('Failed to load orders', e);
        }
    }

    function renderOrdersTable() {
        const tbody = document.getElementById('orders-list-table-body');
        document.getElementById('orders-list-count-badge').textContent = `${ordersList.length} orders total`;

        if (ordersList.length === 0) {
            tbody.innerHTML = `<tr><td colspan="5" class="px-6 py-8 text-center text-slate-500">No transactions recorded yet</td></tr>`;
            const pag = document.getElementById('orders-pagination');
            if (pag) pag.classList.add('hidden');
            return;
        }

        const pag = document.getElementById('orders-pagination');
        if (pag) pag.classList.remove('hidden');

        const totalItems = ordersList.length;
        const totalPages = Math.ceil(totalItems / ordersPageSize);
        if (ordersCurrentPage > totalPages) ordersCurrentPage = Math.max(1, totalPages);

        const startIndex = (ordersCurrentPage - 1) * ordersPageSize;
        const endIndex = Math.min(startIndex + ordersPageSize, totalItems);

        const pageItems = ordersList.slice(startIndex, endIndex);

        let html = '';
        pageItems.forEach(o => {
            let statusBadge = 'bg-indigo-50 text-indigo-700 border-indigo-200';
            if (o.status === 'PROCESSED' || o.status === 'PAYMENT_SUCCESS') statusBadge = 'bg-emerald-50 text-emerald-700 border-emerald-250';
            else if (o.status.includes('FAILED')) statusBadge = 'bg-rose-50 text-rose-700 border-rose-250';

            html += `
                <tr class="hover:bg-slate-50 transition-all">
                    <td class="px-6 py-4 font-bold text-slate-800">#${o.id}</td>
                    <td class="px-6 py-4 text-slate-500">${o.userEmail}</td>
                    <td class="px-6 py-4 font-bold text-slate-900">Rs. ${o.totalAmount.toLocaleString('en-US', {minimumFractionDigits: 2})}</td>
                    <td class="px-6 py-4">
                        <span class="text-[9px] font-bold px-2 py-0.5 rounded-full border ${statusBadge} font-mono">${o.status}</span>
                    </td>
                    <td class="px-6 py-4 text-[10px] text-slate-500 font-mono">${o.orderedAt ? o.orderedAt.substring(0, 19).replace('T', ' ') : ''}</td>
                </tr>
            `;
        });
        tbody.innerHTML = html;

        // Update pagination UI
        const infoEl = document.getElementById('orders-pagination-info');
        if (infoEl) infoEl.textContent = `Showing ${totalItems === 0 ? 0 : startIndex + 1}-${endIndex} of ${totalItems} orders`;

        const btnPrev = document.getElementById('btn-orders-prev');
        if (btnPrev) btnPrev.disabled = (ordersCurrentPage === 1);

        const btnNext = document.getElementById('btn-orders-next');
        if (btnNext) btnNext.disabled = (ordersCurrentPage === totalPages || totalPages === 0);

        const pagesContainer = document.getElementById('orders-pagination-pages');
        if (pagesContainer) {
            pagesContainer.innerHTML = '';
            let startPage = Math.max(1, ordersCurrentPage - 2);
            let endPage = Math.min(totalPages, startPage + 4);
            if (endPage - startPage < 4) {
                startPage = Math.max(1, endPage - 4);
            }

            for (let i = startPage; i <= endPage; i++) {
                const activeClass = i === ordersCurrentPage
                    ? 'bg-violet-600 text-white border-violet-600'
                    : 'bg-white hover:bg-slate-50 text-slate-600 border-slate-200';
                pagesContainer.innerHTML += `
                    <button onclick="goOrdersPage(${i})" class="w-7 h-7 flex items-center justify-center rounded-lg border text-[10px] font-bold transition-all ${activeClass}">${i}</button>
                `;
            }
        }
    }

    function goOrdersPage(page) {
        ordersCurrentPage = page;
        renderOrdersTable();
    }

    function changeOrdersPage(dir) {
        ordersCurrentPage += dir;
        renderOrdersTable();
    }

    // ==========================================
    // TAB: TELEMETRY METRICS CONTROLLERS
    // ==========================================
    function buildLatencyChart() {
        const ctx = document.getElementById('latency-chart').getContext('2d');
        if (latencyChart) {
            latencyChart.data.labels = latencyHistory.labels.length ? latencyHistory.labels : ['Waiting...'];
            latencyChart.data.datasets[0].data = latencyHistory.sync.length ? latencyHistory.sync : [0];
            latencyChart.data.datasets[1].data = latencyHistory.async.length ? latencyHistory.async : [0];
            latencyChart.update('none');
        } else {
            latencyChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: latencyHistory.labels.length ? latencyHistory.labels : ['Waiting...'],
                    datasets: [
                        {
                            label: 'Sync Checkout Latency (ms)',
                            data: latencyHistory.sync.length ? latencyHistory.sync : [0],
                            borderColor: '#a855f7',
                            borderWidth: 2,
                            pointRadius: 3,
                            tension: 0.35,
                            fill: false
                        },
                        {
                            label: 'Async Processing Time (ms)',
                            data: latencyHistory.async.length ? latencyHistory.async : [0],
                            borderColor: '#3b82f6',
                            borderWidth: 2,
                            pointRadius: 3,
                            tension: 0.35,
                            fill: false
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'top',
                            labels: { color: '#475569', font: { size: 10 } }
                        }
                    },
                    scales: {
                        x: { ticks: { color: '#475569', font: { size: 9 } }, grid: { color: 'rgba(0,0,0,0.04)' } },
                        y: { ticks: { color: '#475569', font: { size: 9 } }, grid: { color: 'rgba(0,0,0,0.04)' } }
                    }
                }
            });
        }
    }

    async function fetchTelemetry() {
        try {
            const healthRes = await fetch('<%= request.getContextPath() %>/health?format=json');
            const health = await healthRes.json();

            document.getElementById('metric-uptime').textContent = health.jvm.uptimeString;
            document.getElementById('metric-heap-memory').textContent = health.jvm.heapUsedMB + ' / ' + health.jvm.heapMaxMB + ' MB';
            document.getElementById('metric-active-sessions').textContent = health.performance.activeSessions || 1;
            document.getElementById('metric-threads').textContent = health.jvm.threadCount;

            const timeStr = new Date().toLocaleTimeString('en-US', { hour12: false });
            latencyHistory.labels.push(timeStr);
            latencyHistory.sync.push(health.performance.avgSyncLatencyMs);
            latencyHistory.async.push(health.performance.avgAsyncLatencyMs);

            if (latencyHistory.labels.length > maxDataPoints) {
                latencyHistory.labels.shift();
                latencyHistory.sync.shift();
                latencyHistory.async.shift();
            }
            buildLatencyChart();

            const compList = document.getElementById('components-list');
            let html = '';
            (health.channels || []).forEach(c => {
                let badgeClass = 'bg-emerald-50 text-emerald-700 border-emerald-200';
                if (!c.healthy) badgeClass = 'bg-rose-50 text-rose-700 border-rose-200';

                html += `
                    <div class="flex justify-between items-center p-3 rounded-xl border border-slate-200 bg-white shadow-sm">
                        <div>
                            <div class="text-xs font-bold text-slate-800">${c.name}</div>
                            <div class="text-[9px] text-slate-500 mt-0.5 font-mono">${c.type}</div>
                        </div>
                        <span class="text-[9px] font-mono px-2 py-0.5 rounded border ${badgeClass}">${c.status}</span>
                    </div>
                `;
            });
            compList.innerHTML = html;
        } catch (e) {
            console.error('Failed to fetch telemetry metrics', e);
        }
    }

    async function fetchAudits() {
        try {
            const auditRes = await fetch('<%= request.getContextPath() %>/audit?format=json');
            const auditData = await auditRes.json();
            auditsList = auditData.auditLogs || [];

            renderAuditTable();
        } catch (e) {
            console.error('Failed to fetch audit log entries', e);
        }
    }

    function renderAuditTable() {
        const tbody = document.getElementById('audit-table-body');
        
        if (auditsList.length === 0) {
            tbody.innerHTML = `<tr><td colspan="5" class="px-6 py-8 text-center text-slate-500">No security audit event logs found.</td></tr>`;
            const pag = document.getElementById('audit-pagination');
            if (pag) pag.classList.add('hidden');
            return;
        }
        
        const pag = document.getElementById('audit-pagination');
        if (pag) pag.classList.remove('hidden');
        
        const totalItems = auditsList.length;
        const totalPages = Math.ceil(totalItems / auditPageSize);
        if (auditCurrentPage > totalPages) auditCurrentPage = Math.max(1, totalPages);
        
        const startIndex = (auditCurrentPage - 1) * auditPageSize;
        const endIndex = Math.min(startIndex + auditPageSize, totalItems);
        
        const pageItems = auditsList.slice(startIndex, endIndex);
        
        let html = '';
        pageItems.forEach(l => {
            let actionClass = 'text-slate-700';
            if (l.action === 'PAYMENT_SUCCESS') actionClass = 'text-emerald-700 font-bold';
            else if (l.action.includes('FAILED')) actionClass = 'text-rose-700 font-bold';
            else if (l.action.includes('RESTOCK')) actionClass = 'text-amber-700 font-bold';

            html += `
                <tr class="hover:bg-slate-50 transition-all text-xs">
                    <td class="px-6 py-3 font-bold text-indigo-650 font-mono">#${l.id}</td>
                    <td class="px-6 py-3 ${actionClass}">${l.action}</td>
                    <td class="px-6 py-3 text-slate-700 font-medium">${l.targetType} (${l.targetId})</td>
                    <td class="px-6 py-3 text-slate-500">${l.changedBy}</td>
                    <td class="px-6 py-3 text-right font-mono text-slate-500">${l.timestamp ? l.timestamp.substring(11, 19) : ''}</td>
                </tr>
            `;
        });
        tbody.innerHTML = html;
        
        // Update pagination UI
        const infoEl = document.getElementById('audit-pagination-info');
        if (infoEl) infoEl.textContent = `Showing ${totalItems === 0 ? 0 : startIndex + 1}-${endIndex} of ${totalItems} logs`;
        
        const btnPrev = document.getElementById('btn-audit-prev');
        if (btnPrev) btnPrev.disabled = (auditCurrentPage === 1);
        
        const btnNext = document.getElementById('btn-audit-next');
        if (btnNext) btnNext.disabled = (auditCurrentPage === totalPages || totalPages === 0);
        
        const pagesContainer = document.getElementById('audit-pagination-pages');
        if (pagesContainer) {
            pagesContainer.innerHTML = '';
            let startPage = Math.max(1, auditCurrentPage - 2);
            let endPage = Math.min(totalPages, startPage + 4);
            if (endPage - startPage < 4) {
                startPage = Math.max(1, endPage - 4);
            }
            
            for (let i = startPage; i <= endPage; i++) {
                const activeClass = i === auditCurrentPage 
                    ? 'bg-violet-600 text-white border-violet-600' 
                    : 'bg-white hover:bg-slate-50 text-slate-600 border-slate-200';
                pagesContainer.innerHTML += `
                    <button onclick="goAuditPage(${i})" class="w-7 h-7 flex items-center justify-center rounded-lg border text-[10px] font-bold transition-all ${activeClass}">${i}</button>
                `;
            }
        }
    }

    function goAuditPage(page) {
        auditCurrentPage = page;
        renderAuditTable();
    }
    
    function changeAuditPage(dir) {
        auditCurrentPage += dir;
        renderAuditTable();
    }

    // ==========================================
    // UTILITIES
    // ==========================================
    function showToast(msg, type) {
        const toast = document.getElementById('toast-container');
        toast.className = '';
        toast.classList.remove('hidden');

        if (type === 'success') {
            toast.className = 'w-full px-4 py-3.5 rounded-xl border border-emerald-200 bg-emerald-50 text-emerald-700 font-semibold text-xs transition-all duration-300';
        } else if (type === 'warning') {
            toast.className = 'w-full px-4 py-3.5 rounded-xl border border-amber-200 bg-amber-50 text-amber-700 font-semibold text-xs transition-all duration-300';
        } else {
            toast.className = 'w-full px-4 py-3.5 rounded-xl border border-rose-200 bg-rose-50 text-rose-700 font-semibold text-xs transition-all duration-300';
        }
        
        toast.textContent = msg;
        setTimeout(() => {
            toast.classList.add('hidden');
        }, 6000);
    }

    // ==========================================
    // INITIALIZATION & SPA ROUTING LISTENERS
    // ==========================================
    window.addEventListener('hashchange', handleNavigation);
    
    // Initial load
    initClock();
    if (!window.location.hash) {
        window.location.hash = '#overview';
    } else {
        handleNavigation();
    }
</script>
</body>
</html>
