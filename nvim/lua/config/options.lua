local opt = vim.opt

-- 줄 번호
opt.number = true -- 절대 줄 번호 표시
opt.relativenumber = true -- 현재 줄 기준 상대 번호 (이동에 유용)

-- 들여쓰기
opt.tabstop = 2 -- Tab 키가 차지하는 공간
opt.shiftwidth = 2 -- 자동 들여쓰기 크기
opt.expandtab = true -- Tab을 공백으로 변환
opt.autoindent = true -- 이전 줄의 들여쓰기 유지
opt.smartindent = true -- 구문에 따라 지능적으로 들여쓰기

-- 줄바꿈
opt.wrap = false -- 긴 줄을 자동으로 줄바꿈하지 않음

-- 검색
opt.ignorecase = true -- 대소문자 구분 없이 검색
opt.smartcase = true -- 대문자 포함 시 대소문자 구분
opt.hlsearch = true -- 검색 결과 하이라이트
opt.incsearch = true -- 검색어 입력 중 실시간 하이라이트

-- 화면 표시
opt.cursorline = true -- 현재 줄 하이라이트
opt.termguicolors = true -- 24-bit 컬러 지원 (테마 색상 제대로 표시)
opt.signcolumn = "yes" -- LSP/git 표시용 왼쪽 여백 항상 표시 (흔들림 방지)
opt.scrolloff = 8 -- 커서 위아래로 최소 8줄 여백 유지
opt.sidescrolloff = 8 -- 커서 좌우로 최소 8칸 여백 유지

-- 분할
opt.splitright = true -- 세로 분할 시 오른쪽에 열기
opt.splitbelow = true -- 가로 분할 시 아래에 열기

-- 클립보드
opt.clipboard = "unnamedplus" -- 시스템 클립보드와 공유 (yank = 복사)

-- 파일 저장 관련
opt.backup = false -- 백업 파일 생성 안 함
opt.swapfile = false -- 스왑 파일 생성 안 함
opt.undofile = true -- 실행 취소 히스토리를 파일로 저장 (재시작 후에도 유지)

-- 성능
opt.updatetime = 250 -- CursorHold 트리거 속도 (기본 4000ms → 250ms)
opt.timeoutlen = 500 -- 키 시퀀스 대기 시간 (which-key 팝업 속도)

-- 기타
opt.mouse = "a" -- 마우스 활성화 (모든 모드)
opt.showmode = false -- 모드 표시 안 함 (lualine이 대신 표시)
opt.completeopt = "menuone,noselect" -- 자동완성 동작
