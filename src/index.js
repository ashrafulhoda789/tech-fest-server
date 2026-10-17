import { env } from "cloudflare:workers";
import express from "express";
import { httpServerHandler } from "cloudflare:node";
import cors from "cors";
import bcrypt from 'bcryptjs';

const app = express();

app.use(cors({
	origin: "https://event-management-client.asrafulhoda789.workers.dev",
	credentials: true,
	methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
	allowedHeaders: ["Content-Type", "Authorization"]
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));


app.get("/", (req, res) => {
	res.json({
		success: true,
		message: "Express.js running on Cloudflare Workers!"
	});
});


const requireAdminAuth = async (req, res, next) => {
	try {
		const authHeader = req.headers.authorization;

		if (!authHeader || !authHeader.startsWith("Bearer ")) {
			return res.status(401).json({
				success: false,
				message: "Unauthorized access"
			});
		}

		const token = authHeader.split(" ")[1];

		if (!token || token === "undefined" || token === "null") {
			return res.status(401).json({
				success: false,
				message: "Unauthorized: Invalid session."
			});
		}

		const adminCheck = await env.DB.prepare('SELECT id, email FROM admins WHERE id = ?').bind(token).first();

		if (!adminCheck) {
			return res.status(403).json({
				success: false,
				message: "Forbidden: Admin session expired or not found."
			});
		}

		req.admin = adminCheck;
		next();

	} catch (error) {
		console.error("Auth Middleware Error:", error);
		return res.status(500).json({
			success: false,
			message: "Internal server error during authentication."
		});
	}
};


app.post('/api/auth/sign-up', async (req, res) => {
	try {
		const { email, password, name } = req.body;

		if (!email || !password || !name) {
			return res.status(400).json({ success: false, message: "All fields are required." });
		}

		const existing = await env.DB.prepare('SELECT * FROM admins WHERE email = ?').bind(email).first();
		if (existing) {
			return res.status(400).json({ success: false, message: "Admin already exists." });
		}

		const hashedPassword = await bcrypt.hash(password, 10);

		await env.DB.prepare(`
            INSERT INTO admins (email, password, name) 
            VALUES (?, ?, ?)
        `).bind(email, hashedPassword, name).run();

		return res.status(201).json({
			success: true,
			message: "Admin registered successfully!"
		});
	} catch (error) {
		console.error("Sign Up Error:", error);
		return res.status(500).json({ success: false, message: error.message });
	}
});

app.post('/api/auth/sign-in', async (req, res) => {
	try {
		const { email, password } = req.body;

		if (!email || !password) {
			return res.status(400).json({ success: false, message: "Email and password are required." });
		}

		const admin = await env.DB.prepare('SELECT * FROM admins WHERE email = ?').bind(email).first();

		let isPasswordValid = false;
		if (admin) {
			isPasswordValid = await bcrypt.compare(password, admin.password);
		}

		if (!admin || !isPasswordValid) {
			return res.status(401).json({ success: false, message: "Invalid email or password." });
		}

		return res.json({
			success: true,
			message: "Login successful!",
			data: {
				id: admin.id,
				email: admin.email,
				name: admin.name,
				role: "Administrator"
			}
		});
	} catch (error) {
		console.error("Sign In Error:", error);
		return res.status(500).json({ success: false, message: error.message });
	}
});

app.get('/api/admin/fests', async (req, res) => {
	try {
		const festsResult = await env.DB.prepare('SELECT * FROM fests ORDER BY start_date DESC').all();
		const fests = festsResult.results || [];

		const fullFests = [];

		for (const fest of fests) {
			const daysResult = await env.DB.prepare('SELECT * FROM fest_days WHERE fest_id = ?').bind(fest.id).all();
			const days = daysResult.results || [];

			const fullDays = [];
			for (const day of days) {
				const sessionsResult = await env.DB.prepare('SELECT * FROM fest_sessions WHERE day_id = ?').bind(day.id).all();
				fullDays.push({
					...day,
					sessions: sessionsResult.results || []
				});
			}

			fullFests.push({
				...fest,
				days: fullDays
			});
		}

		return res.json({
			success: true,
			data: fullFests
		});
	} catch (error) {
		console.error("Fetch Fests Error:", error);
		return res.status(500).json({
			success: false,
			message: "Failed to fetch fests",
		});
	}
});

app.post('/api/admin/fests', requireAdminAuth, async (req, res) => {
	try {
		const { title, startDate, endDate, days } = req.body;

		if (!title || !days || !Array.isArray(days)) {
			return res.status(400).json({
				success: false,
				message: "Invalid payload data."
			});
		}

		const festResult = await env.DB.prepare(`
            INSERT INTO fests (title, start_date, end_date) 
            VALUES (?, ?, ?)
            RETURNING id
        `).bind(title, startDate, endDate).first();

		const festId = festResult.id;

		for (const day of days) {
			const dayResult = await env.DB.prepare(`
                INSERT INTO fest_days (fest_id, day_number, date_str, theme) 
                VALUES (?, ?, ?, ?)
                RETURNING id
            `).bind(festId, day.dayNumber, day.dateStr, day.theme).first();

			const dayId = dayResult.id;

			if (day.sessions && Array.isArray(day.sessions)) {
				for (const session of day.sessions) {
					await env.DB.prepare(`
                        INSERT INTO fest_sessions (day_id, start_time, end_time, category, title, description) 
                        VALUES (?, ?, ?, ?, ?, ?)
                    `).bind(
						dayId,
						session.startTime,
						session.endTime,
						session.category,
						session.title,
						session.description,

					).run();
				}
			}
		}

		return res.status(201).json({
			success: true,
			message: "Fest schedule created successfully!"
		});

	} catch (error) {
		console.error("Fest Creation Error:", error);
		return res.status(500).json({
			success: false,
			message: error.message || "Internal Server Error"
		});
	}
});

app.put('/api/admin/fests/:id', requireAdminAuth, async (req, res) => {
	try {
		const { id } = req.params;
		const { title, startDate, endDate, days } = req.body;

		if (!title || !days || !Array.isArray(days)) {
			return res.status(400).json({
				success: false,
				message: "Invalid payload data for update."
			});
		}

		await env.DB.prepare(` UPDATE fests 
            SET title = ?, start_date = ?, end_date = ? 
            WHERE id = ?
        `).bind(title, startDate, endDate, id).run();

		const oldDays = await env.DB.prepare('SELECT id FROM fest_days WHERE fest_id = ?').bind(id).all();
		const oldDayIds = oldDays.results || [];

		for (const d of oldDayIds) {
			await env.DB.prepare('DELETE FROM fest_sessions WHERE day_id = ?').bind(d.id).run();
		}
		await env.DB.prepare('DELETE FROM fest_days WHERE fest_id = ?').bind(id).run();

		for (const day of days) {
			const dayResult = await env.DB.prepare(`
                INSERT INTO fest_days (fest_id, day_number, date_str, theme) 
                VALUES (?, ?, ?, ?)
                RETURNING id
            `).bind(id, day.dayNumber || day.day_number, day.dateStr || day.date_str, day.theme).first();

			const dayId = dayResult.id;

			if (day.sessions && Array.isArray(day.sessions)) {
				for (const session of day.sessions) {
					await env.DB.prepare(`
                        INSERT INTO fest_sessions (day_id, start_time, end_time, category, title, description) 
                        VALUES (?, ?, ?, ?, ?, ?)
                    `).bind(
						dayId,
						session.startTime || session.start_time,
						session.endTime || session.end_time,
						session.category,
						session.title,
						session.description,
					).run();
				}
			}
		}

		return res.json({
			success: true,
			message: "Fest schedule updated successfully!"
		});

	} catch (error) {
		console.error("Fest Update Error:", error);
		return res.status(500).json({
			success: false,
			message: error.message || "Internal Server Error"
		});
	}
});

app.delete('/api/admin/fests/:id', requireAdminAuth, async (req, res) => {
	try {
		const { id } = req.params;
		await env.DB.prepare('DELETE FROM fests WHERE id = ?').bind(id).run();
		return res.json({ success: true, message: "Fest deleted successfully" });
	} catch (error) {
		return res.status(500).json({ success: false, message: error.message });
	}
});


// Speakers API

app.get('/api/admin/speakers', async (req, res) => {
	try {
		const result = await env.DB.prepare('SELECT * FROM speakers ORDER BY created_at DESC').all();
		return res.json({
			success: true,
			data: result.results || []
		});
	} catch (error) {
		console.error("Fetch Speakers Error:", error);
		return res.status(500).json({
			success: false,
			message: "Failed to fetch speakers",
		});
	}
});


app.post('/api/admin/speakers', requireAdminAuth, async (req, res) => {
	try {
		const { name, image, designation, country, description } = req.body;

		if (!name || !designation) {
			return res.status(400).json({
				success: false,
				message: "Name and designation are required fields."
			});
		}

		const result = await env.DB.prepare(`
            INSERT INTO speakers (name, image, designation, country, description) 
            VALUES (?, ?, ?, ?, ?)
            RETURNING id
        `).bind(name, image || "", designation, country || "", description || "").first();

		return res.status(201).json({
			success: true,
			message: "Speaker added successfully!",
			data: { id: result.id, name, image, designation, country, description }
		});

	} catch (error) {
		console.error("Speaker Creation Error:", error);
		return res.status(500).json({
			success: false,
			message: error.message || "Internal Server Error"
		});
	}
});

app.put('/api/admin/speakers/:id', requireAdminAuth, async (req, res) => {
	try {
		const { id } = req.params;
		const { name, image, designation, country, description } = req.body;

		if (!name || !designation) {
			return res.status(400).json({
				success: false,
				message: "Name and designation are required for update."
			});
		}

		await env.DB.prepare(`
            UPDATE speakers 
            SET name = ?, image = ?, designation = ?, country = ?, description = ? 
            WHERE id = ?
        `).bind(name, image || "", designation, country || "", description || "", id).run();

		return res.json({
			success: true,
			message: "Speaker updated successfully!"
		});

	} catch (error) {
		console.error("Speaker Update Error:", error);
		return res.status(500).json({
			success: false,
			message: error.message || "Internal Server Error"
		});
	}
});

app.delete('/api/admin/speakers/:id', requireAdminAuth, async (req, res) => {
	try {
		const { id } = req.params;
		await env.DB.prepare('DELETE FROM speakers WHERE id = ?').bind(id).run();

		return res.json({
			success: true,
			message: "Speaker deleted successfully!"
		});
	} catch (error) {
		console.error("Speaker Delete Error:", error);
		return res.status(500).json({
			success: false,
			message: error.message
		});
	}
});


// Contact api
app.post('/api/contact', async (req, res) => {
	try {
		const { firstName, lastName, email, phone, organisation, subject, message } = req.body;

		if (!firstName || !email || !message) {
			return res.status(400).json({ success: false, message: "First name, email, and message are required." });
		}

		await env.DB.prepare(`
            INSERT INTO contacts (first_name, last_name, email, phone, organisation, subject, message) 
            VALUES (?, ?, ?, ?, ?, ?, ?)
        `).bind(firstName, lastName || "", email, phone || "", organisation || "", subject || "", message).run();

		return res.status(201).json({
			success: true,
			message: "Contact message sent successfully!"
		});
	} catch (error) {
		console.error("Contact Submit Error:", error);
		return res.status(500).json({ success: false, message: error.message });
	}
});


app.get('/api/admin/contacts', requireAdminAuth, async (req, res) => {
	try {
		const result = await env.DB.prepare('SELECT * FROM contacts ORDER BY created_at DESC').all();
		return res.json({
			success: true,
			data: result.results || []
		});
	} catch (error) {
		console.error("Fetch Contacts Error:", error);
		return res.status(500).json({ success: false, message: "Failed to fetch contact messages" });
	}
});

app.delete('/api/admin/contacts/:id', requireAdminAuth, async (req, res) => {
	try {
		const { id } = req.params;
		await env.DB.prepare('DELETE FROM contacts WHERE id = ?').bind(id).run();
		return res.json({
			success: true,
			message: "Contact message deleted successfully!"
		});
	} catch (error) {
		console.error("Delete Contact Error:", error);
		return res.status(500).json({ success: false, message: error.message });
	}
});


// Registration api
app.post('/api/register', async (req, res) => {
	try {
		const { firstName, lastName, email, whatsapp, organisation, attendingAs, notes } = req.body;

		if (!firstName || !email) {
			return res.status(400).json({ success: false, message: "First name and email are required." });
		}

		// Check if email already registered
		const existing = await env.DB.prepare('SELECT * FROM registrations WHERE email = ?').bind(email).first();
		if (existing) {
			return res.status(400).json({ success: false, message: "This email is already registered for the tech fest." });
		}

		await env.DB.prepare(`
            INSERT INTO registrations (first_name, last_name, email, whatsapp, organisation, attending_as, notes) 
            VALUES (?, ?, ?, ?, ?, ?, ?)
        `).bind(firstName, lastName || "", email, whatsapp || "", organisation || "", attendingAs || "Participant", notes || "").run();

		return res.status(201).json({
			success: true,
			message: "Registration interest submitted successfully!"
		});
	} catch (error) {
		console.error("Registration Submit Error:", error);
		return res.status(500).json({ success: false, message: error.message });
	}
});

app.get('/api/admin/registrations', requireAdminAuth, async (req, res) => {
	try {
		const result = await env.DB.prepare('SELECT * FROM registrations ORDER BY created_at DESC').all();
		return res.json({
			success: true,
			data: result.results || []
		});
	} catch (error) {
		console.error("Fetch Registrations Error:", error);
		return res.status(500).json({ success: false, message: "Failed to fetch registrations" });
	}
});

app.delete('/api/admin/registrations/:id', requireAdminAuth, async (req, res) => {
	try {
		const { id } = req.params;
		await env.DB.prepare('DELETE FROM registrations WHERE id = ?').bind(id).run();
		return res.json({
			success: true,
			message: "Registration deleted successfully!"
		});
	} catch (error) {
		console.error("Delete Registration Error:", error);
		return res.status(500).json({ success: false, message: error.message });
	}
});

app.listen(3000);

export default httpServerHandler({ port: 3000 });
