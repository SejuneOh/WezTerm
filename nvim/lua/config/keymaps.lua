local keymap = vim.keymap

-- 검색 하이라이트 해제
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "검색 하이라이트 해제" })

-- 파일 저장
keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "파일 저장" })
keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>", { desc = "파일 저장" })

-- 비주얼 모드에서 들여쓰기 유지
keymap.set("v", "<", "<gv", { desc = "들여쓰기 유지 (왼쪽)" })
keymap.set("v", ">", ">gv", { desc = "들여쓰기 유지 (오른쪽)" })

-- 비주얼 모드 붙여넣기 시 레지스터 유지
keymap.set("x", "p", [["_dP]], { desc = "붙여넣기 (레지스터 유지)" })

-- 전체 선택
keymap.set("n", "<C-a>", "ggVG", { desc = "전체 선택" })

-- 창 분할
keymap.set("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "세로 분할" })
keymap.set("n", "<leader>sh", "<cmd>split<CR>", { desc = "가로 분할" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "분할 크기 균등화" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "현재 분할 닫기" })
