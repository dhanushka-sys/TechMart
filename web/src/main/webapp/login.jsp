<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TechMart Enterprise — Authentication</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
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
                radial-gradient(at 0% 0%, rgba(124, 58, 237, 0.07) 0, transparent 50%),
                radial-gradient(at 100% 100%, rgba(99, 102, 241, 0.07) 0, transparent 50%);
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }

        .glass-panel {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(226, 232, 240, 0.8);
            box-shadow: 0 20px 40px -15px rgba(148, 163, 184, 0.22);
        }

        .glow-btn {
            background: linear-gradient(135deg, #7c3aed, #6366f1);
            box-shadow: 0 4px 15px rgba(124, 58, 237, 0.25);
            transition: all 0.25s ease;
        }
        .glow-btn:hover {
            box-shadow: 0 6px 20px rgba(124, 58, 237, 0.45);
            transform: translateY(-1px);
        }
    </style>
</head>
<body class="min-h-screen text-slate-800 font-sans flex items-center justify-center p-4 relative">

<!-- Glowing decorative backdrops -->
<div class="absolute top-[15%] left-[10%] w-[35%] h-[35%] rounded-full bg-violet-500/5 blur-[120px] pointer-events-none"></div>
<div class="absolute bottom-[15%] right-[10%] w-[30%] h-[30%] rounded-full bg-indigo-500/5 blur-[120px] pointer-events-none"></div>

<div class="w-full max-w-md glass-panel rounded-2xl p-8 border relative z-10 flex flex-col gap-6">
    
    <div class="flex flex-col items-center gap-3">
        <div class="w-10 h-10 rounded-2xl flex items-center justify-center text-lg font-bold shadow-md" style="background: linear-gradient(135deg, #a855f7, #6366f1); color: #fff;">⚡</div>
        <h1 class="text-2xl font-extrabold tracking-tight font-outfit text-slate-900">TechMart Enterprise</h1>
        <p class="text-xs text-indigo-650 font-semibold text-center">Jakarta EE 10 • EJB & Messaging Backend System</p>
    </div>

    <!-- Toggle Tabs -->
    <div class="flex p-1 rounded-xl bg-slate-100 border border-slate-200/60">
        <button id="tab-login" onclick="switchTab('login')" class="flex-1 py-2 text-xs font-bold rounded-lg bg-white text-violet-700 border border-slate-200 shadow-sm transition-all">
            Sign In
        </button>
        <button id="tab-register" onclick="switchTab('register')" class="flex-1 py-2 text-xs font-bold rounded-lg text-slate-500 hover:text-slate-800 transition-all">
            Register
        </button>
    </div>

    <!-- Toast message -->
    <div id="auth-toast" class="fixed top-5 left-1/2 -translate-x-1/2 px-5 py-3.5 rounded-xl shadow-lg font-outfit text-xs z-50 hidden transition-all"></div>

    <!-- Forms -->
    <div id="login-form-container" class="space-y-4">
        <form onsubmit="handleLogin(event)" class="space-y-4">
            <div>
                <label class="text-[10px] font-bold text-slate-500 uppercase tracking-widest block mb-2 font-outfit">Email Address</label>
                <input type="email" required id="login-email" placeholder="admin@techmart.com" value="kamal@techmart.com"
                       class="w-full text-xs px-3.5 py-3 rounded-xl border border-slate-200 bg-slate-50 text-slate-900 outline-none focus:bg-white focus:border-violet-500/50 transition-all">
            </div>
            <div>
                <label class="text-[10px] font-bold text-slate-500 uppercase tracking-widest block mb-2 font-outfit">Password</label>
                <input type="password" required id="login-password" placeholder="••••••••" value="securepass"
                       class="w-full text-xs px-3.5 py-3 rounded-xl border border-slate-200 bg-slate-50 text-slate-900 outline-none focus:bg-white focus:border-violet-500/50 transition-all">
            </div>
            <button type="submit" class="w-full text-xs font-bold py-3.5 rounded-xl text-white glow-btn mt-2">
                Authorize Session
            </button>
        </form>
    </div>

    <div id="register-form-container" class="space-y-4 hidden">
        <form onsubmit="handleRegister(event)" class="space-y-4">
            <div>
                <label class="text-[10px] font-bold text-slate-500 uppercase tracking-widest block mb-2 font-outfit">Full Name</label>
                <input type="text" required id="reg-name" placeholder="Kamal Fernando"
                       class="w-full text-xs px-3.5 py-3 rounded-xl border border-slate-200 bg-slate-50 text-slate-900 outline-none focus:bg-white focus:border-violet-500/50 transition-all">
            </div>
            <div>
                <label class="text-[10px] font-bold text-slate-500 uppercase tracking-widest block mb-2 font-outfit">Email Address</label>
                <input type="email" required id="reg-email" placeholder="kamal@techmart.com"
                       class="w-full text-xs px-3.5 py-3 rounded-xl border border-slate-200 bg-slate-50 text-slate-900 outline-none focus:bg-white focus:border-violet-500/50 transition-all">
            </div>
            <div>
                <label class="text-[10px] font-bold text-slate-500 uppercase tracking-widest block mb-2 font-outfit">Password</label>
                <input type="password" required id="reg-password" placeholder="••••••••"
                       class="w-full text-xs px-3.5 py-3 rounded-xl border border-slate-200 bg-slate-50 text-slate-900 outline-none focus:bg-white focus:border-violet-500/50 transition-all">
            </div>
            <button type="submit" class="w-full text-xs font-bold py-3.5 rounded-xl text-white glow-btn mt-2">
                Register Account
            </button>
        </form>
    </div>

</div>

<script>
    let activeTab = 'login';

    function switchTab(tab) {
        activeTab = tab;
        const tabLoginBtn = document.getElementById('tab-login');
        const tabRegBtn = document.getElementById('tab-register');
        const loginContainer = document.getElementById('login-form-container');
        const regContainer = document.getElementById('register-form-container');

        if (tab === 'login') {
            tabLoginBtn.className = 'flex-1 py-2 text-xs font-bold rounded-lg bg-white text-violet-750 border border-slate-200 shadow-sm transition-all';
            tabRegBtn.className = 'flex-1 py-2 text-xs font-bold rounded-lg text-slate-500 hover:text-slate-800 transition-all';
            loginContainer.classList.remove('hidden');
            regContainer.classList.add('hidden');
        } else {
            tabRegBtn.className = 'flex-1 py-2 text-xs font-bold rounded-lg bg-white text-violet-750 border border-slate-200 shadow-sm transition-all';
            tabLoginBtn.className = 'flex-1 py-2 text-xs font-bold rounded-lg text-slate-500 hover:text-slate-800 transition-all';
            loginContainer.classList.add('hidden');
            regContainer.classList.remove('hidden');
        }
    }

    async function handleLogin(e) {
        e.preventDefault();
        const email = document.getElementById('login-email').value;
        const pass = document.getElementById('login-password').value;
        const toast = document.getElementById('auth-toast');

        try {
            const formData = new URLSearchParams();
            formData.append('action', 'login');
            formData.append('email', email);
            formData.append('password', pass);

            const res = await fetch('<%= request.getContextPath() %>/auth', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: formData
            });

            if (res.ok) {
                const data = await res.json();
                toast.textContent = "Login successful! Redirecting...";
                toast.className = "fixed top-5 left-1/2 -translate-x-1/2 bg-emerald-600 text-white px-5 py-3.5 rounded-xl shadow-lg font-outfit text-xs z-50 transition-all";
                toast.classList.remove('hidden');
                setTimeout(() => {
                    window.location.href = '<%= request.getContextPath() %>/dashboard.jsp';
                }, 1500);
            } else {
                let errorMsg = "Invalid email or password";
                try {
                    const data = await res.json();
                    errorMsg = data.message || errorMsg;
                } catch(parseErr) {}
                
                toast.textContent = errorMsg;
                toast.className = "fixed top-5 left-1/2 -translate-x-1/2 bg-rose-600 text-white px-5 py-3.5 rounded-xl shadow-lg font-outfit text-xs z-50 transition-all";
                toast.classList.remove('hidden');
                setTimeout(() => {
                    toast.classList.add('hidden');
                }, 3000);
            }
        } catch (err) {
            console.error(err);
            toast.textContent = "Connection error. Please try again.";
            toast.className = "fixed top-5 left-1/2 -translate-x-1/2 bg-rose-600 text-white px-5 py-3.5 rounded-xl shadow-lg font-outfit text-xs z-50 transition-all";
            toast.classList.remove('hidden');
            setTimeout(() => {
                toast.classList.add('hidden');
            }, 3000);
        }
    }

    async function handleRegister(e) {
        e.preventDefault();
        const name = document.getElementById('reg-name').value;
        const email = document.getElementById('reg-email').value;
        const pass = document.getElementById('reg-password').value;
        const toast = document.getElementById('auth-toast');

        try {
            const url = `<%= request.getContextPath() %>/users?action=create&name=${encodeURIComponent(name)}&email=${encodeURIComponent(email)}&password=${encodeURIComponent(pass)}`;
            const res = await fetch(url);
            const text = await res.text();
            
            if (res.ok) {
                toast.textContent = text || "Registration successful!";
                toast.className = "fixed top-5 left-1/2 -translate-x-1/2 bg-emerald-600 text-white px-5 py-3.5 rounded-xl shadow-lg font-outfit text-xs z-50 transition-all";
                toast.classList.remove('hidden');
                setTimeout(() => {
                    toast.classList.add('hidden');
                    switchTab('login');
                }, 3000);
            } else {
                toast.textContent = text || "Registration failed!";
                toast.className = "fixed top-5 left-1/2 -translate-x-1/2 bg-rose-600 text-white px-5 py-3.5 rounded-xl shadow-lg font-outfit text-xs z-50 transition-all";
                toast.classList.remove('hidden');
                setTimeout(() => {
                    toast.classList.add('hidden');
                }, 3000);
            }
        } catch (err) {
            console.error(err);
            toast.textContent = "Connection error. Please try again.";
            toast.className = "fixed top-5 left-1/2 -translate-x-1/2 bg-rose-600 text-white px-5 py-3.5 rounded-xl shadow-lg font-outfit text-xs z-50 transition-all";
            toast.classList.remove('hidden');
            setTimeout(() => {
                toast.classList.add('hidden');
            }, 3000);
        }
    }
</script>
</body>
</html>
