const songDaoState = {
  get(key, fallback) {
    try {
      const value = localStorage.getItem(key);
      return value ? JSON.parse(value) : fallback;
    } catch {
      return fallback;
    }
  },
  set(key, value) {
    localStorage.setItem(key, JSON.stringify(value));
  }
};

function showToast(message) {
  let toast = document.querySelector(".toast");
  if (!toast) {
    toast = document.createElement("div");
    toast.className = "toast";
    document.body.appendChild(toast);
  }
  toast.textContent = message;
  toast.classList.add("show");
  window.setTimeout(() => toast.classList.remove("show"), 2200);
}

function setupToday() {
  const doneButton = document.querySelector("[data-complete-action]");
  const note = document.querySelector("[data-note]");
  const noteStatus = document.querySelector("[data-note-status]");
  const rhythm = document.querySelector("[data-rhythm-count]");
  if (!doneButton) return;

  const today = new Date().toISOString().slice(0, 10);
  const completions = songDaoState.get("songdao-completions", {});
  const savedNote = songDaoState.get("songdao-note", "");
  if (note) note.value = savedNote;

  function paint() {
    const complete = Boolean(completions[today]);
    doneButton.textContent = complete ? "Đã hoàn thành hôm nay" : "Đánh dấu đã làm xong";
    doneButton.classList.toggle("btn-primary", !complete);
    doneButton.classList.toggle("btn-quiet", complete);
    if (rhythm) {
      const count = Object.values(completions).filter(Boolean).length;
      rhythm.textContent = `${Math.min(count, 7)}/7 ngày`;
    }
  }

  doneButton.addEventListener("click", () => {
    completions[today] = !completions[today];
    songDaoState.set("songdao-completions", completions);
    paint();
    showToast(completions[today] ? "Đã lưu việc hôm nay riêng tư trên máy này." : "Đã bỏ đánh dấu hôm nay.");
  });

  if (note) {
    note.addEventListener("input", () => {
      songDaoState.set("songdao-note", note.value);
      if (noteStatus) noteStatus.textContent = note.value.trim() ? "Đã lưu tự động" : "Ghi chú riêng tư";
    });
  }
  paint();
}

function setupPractice() {
  const select = document.querySelector("[data-season-select]");
  const output = document.querySelector("[data-practice-output]");
  if (!select || !output) return;
  const practices = {
    ordinary: ["Chọn một điều nhỏ để tiết chế hoặc phục vụ âm thầm.", "Đọc Tin Mừng hôm nay và viết một câu.", "Cầu nguyện trước bữa tối, một mình hoặc cùng cả nhà."],
    lent: ["Chọn một hy sinh nhỏ và dâng cho một người đang cần.", "Ăn đơn giản hơn hôm nay.", "Xét mình 5 phút trước khi ngủ."],
    easter: ["Nói một lời biết ơn thật cụ thể.", "Cầu nguyện cho một người hoặc một gia đình đang xa Chúa.", "Chia sẻ một niềm vui phục sinh trong nhà."],
    advent: ["Dọn một góc nhỏ để cầu nguyện.", "Thắp một lời hy vọng cho người đang mệt.", "Giữ 10 phút thinh lặng trước Chúa."]
  };
  function update() {
    const list = practices[select.value];
    output.innerHTML = list.map((item, index) => `<div class="list-item"><span class="meta">Gợi ý ${index + 1}</span><p>${item}</p></div>`).join("");
  }
  select.addEventListener("change", update);
  update();
}

function setupCalendar() {
  const search = document.querySelector("[data-calendar-search]");
  const days = Array.from(document.querySelectorAll("[data-day]"));
  if (!search || !days.length) return;
  search.addEventListener("input", () => {
    const query = search.value.trim().toLowerCase();
    days.forEach((day) => {
      day.hidden = query && !day.textContent.toLowerCase().includes(query);
    });
  });
}

function setupParish() {
  const select = document.querySelector("[data-parish-select]");
  const name = document.querySelector("[data-parish-name]");
  const mass = document.querySelector("[data-parish-mass]");
  const cache = document.querySelector("[data-cache-state]");
  if (!select || !name || !mass) return;
  const data = {
    "tan-dinh": ["Giáo xứ Tân Định", "Chúa Nhật · 07:00 · 17:30"],
    "duc-ba": ["Nhà thờ Đức Bà Sài Gòn", "Chúa Nhật · 09:30 · 16:00"],
    "ba-chuong": ["Giáo xứ Ba Chuông", "Chúa Nhật · 06:00 · 18:00"]
  };
  select.addEventListener("change", () => {
    const value = data[select.value];
    name.textContent = value[0];
    mass.textContent = value[1];
    if (cache) cache.textContent = "Đã lưu để dùng offline";
    showToast(`Đã chọn ${value[0]}.`);
  });
}

function setupProgress() {
  const days = Array.from(document.querySelectorAll("[data-check-day]"));
  const count = document.querySelector("[data-week-count]");
  const meter = document.querySelector("[data-week-meter]");
  if (!days.length) return;
  function paint() {
    const done = days.filter((day) => day.classList.contains("is-done")).length;
    if (count) count.textContent = `${done}/7 ngày`;
    if (meter) meter.style.setProperty("--value", `${(done / 7) * 100}%`);
  }
  days.forEach((day) => {
    day.addEventListener("click", () => {
      day.classList.toggle("is-done");
      paint();
    });
  });
  paint();
}

function setupWaitlist() {
  const form = document.querySelector("[data-waitlist]");
  if (!form) return;
  form.addEventListener("submit", (event) => {
    event.preventDefault();
    const input = form.querySelector("input");
    const valid = input && input.value.includes("@");
    showToast(valid ? "Đã ghi nhận email mẫu cho bản thử nghiệm." : "Nhập email hợp lệ để tiếp tục.");
  });
}

setupToday();
setupPractice();
setupCalendar();
setupParish();
setupProgress();
setupWaitlist();
