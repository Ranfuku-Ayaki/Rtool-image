TransPicture <- function() {
  # ============================================================================
============================================================================
  
  # 语言检测
  sys_lang <- Sys.getlocale("LC_CTYPE")
  is_cn <- grepl("Chinese|zh_CN|zh-CN", sys_lang, ignore.case = TRUE)
  
  # 支持格式
  all_formats <- c("png", "jpg", "jpeg", "webp", "tiff", "bmp", "gif", "svg")
  
  # 双语提示
  msg <- list(
    installing = if(is_cn) "正在安装 magick 包..." else "Installing magick...",
    loop_start = if(is_cn) "========== 进入循环转换模式（输入 quit 或 q 退出）==========" else "========== Loop Mode (type quit/q to exit) ==========",
    step1 = if(is_cn) "========== 工作目录 ==========" else "========== Workspace ==========",
    current_dir = if(is_cn) "当前目录：" else "Current dir:",
    auto_input = if(is_cn) "✅ 自动创建 Input 文件夹" else "✅ Auto-created Input folder",
    folder_list = if(is_cn) "可用文件夹：" else "Folders:",
    step2 = if(is_cn) "========== 选择输入文件夹 ==========" else "========== Select Input Folder ==========",
    input_prompt = if(is_cn) "输入编号（quit 退出）：" else "Enter number (quit to exit):",
    warn_sys = if(is_cn) "⚠️ 疑似系统文件夹，确定使用？(y/n)" else "⚠️ System folder, confirm?(y/n)",
    selected_input = if(is_cn) "已选输入：%s" else "Input: %s",
    invalid_num = if(is_cn) "无效输入" else "Invalid input",
    step3 = if(is_cn) "========== 选择图片（多选：空格分隔）==========" else "========== Select Images (space sep) ==========",
    no_images = if(is_cn) "无图片" else "No images",
    img_prompt = if(is_cn) "输入图片编号（quit 退出）：" else "Image numbers (quit to exit):",
    selected_img = if(is_cn) "已选图片：%d 张" else "Selected: %d images",
    step4 = if(is_cn) "========== 选择输出文件夹 ==========" else "========== Select Output Folder ==========",
    output_prompt = if(is_cn) "输入编号 | new 新建 | quit 退出：" else "Number | new | quit:",
    new_folder_name = if(is_cn) "新文件夹名称：" else "New folder name:",
    folder_exists = if(is_cn) "已存在" else "Exists",
    folder_created = if(is_cn) "✅ 已创建：%s" else "✅ Created: %s",
    selected_output = if(is_cn) "已选输出：%s" else "Output: %s",
    step5 = if(is_cn) "========== 选择导出格式（多选：空格分隔）==========" else "========== Select Output Formats ==========",
    fmt_list = if(is_cn) "支持格式：" else "Formats:",
    fmt_prompt = if(is_cn) "输入格式（quit 退出）：" else "Formats (quit to exit):",
    invalid_fmt = if(is_cn) "格式不支持" else "Invalid format",
    selected_fmt = if(is_cn) "已选导出格式：%s" else "Export formats: %s",
    jpg_quality = if(is_cn) "JPG 质量 1-100（默认95）：" else "JPG quality 1-100 (default 95):",
    converting = if(is_cn) "\n开始转换..." else "\nConverting...",
    success = if(is_cn) "✅ %s → %s" else "✅ %s → %s",
    fail = if(is_cn) "❌ %s 失败：%s" else "❌ %s failed: %s",
    done = if(is_cn) "\n========== 本轮完成 ==========" else "\n========== Task Done ==========",
    total_suc = if(is_cn) "成功：%d 个文件" else "Success: %d files",
    total_fail = if(is_cn) "失败：%d 个" else "Failed: %d",
    quit_msg = if(is_cn) "👋 已退出转换工具" else "👋 Exited",
    repeat_msg = if(is_cn) "\n→ 准备下一轮转换..." else "\n→ Next round..."
  )
  
  # 安装依赖
  if (!require("magick", quietly = TRUE)) {
    message(msg$installing)
    install.packages("magick")
    library(magick)
  }
  
  # 自动创建 Input
  current_dir <- getwd()
  if (!dir.exists("Input")) {
    dir.create("Input")
    img <- image_blank(10, 10, "white")
    image_write(img, file.path("Input", "empty.png"))
    cat(msg$auto_input, "\n")
  }
  
  # 循环主逻辑
  repeat {
    cat("\n\n", msg$loop_start, "\n")
    all_dirs <- list.dirs(current_dir, full.names = FALSE, recursive = FALSE)
    all_dirs <- all_dirs[!grepl("^\\.", all_dirs)]
    
    # ------------------------------
    # 步骤1：显示文件夹
    # ------------------------------
    cat(msg$step1, "\n", msg$current_dir, current_dir, "\n")
    cat(msg$folder_list, "\n")
    for (i in seq_along(all_dirs)) cat(sprintf("  [%d] %s\n", i, all_dirs[i]))
    
    # ------------------------------
    # 步骤2：选择输入文件夹
    # ------------------------------
    cat("\n", msg$step2, "\n")
    input_folder <- NULL
    input_path <- NULL
    repeat {
      c <- trimws(readline(msg$input_prompt))
      if (tolower(c) %in% c("quit", "q")) { message(msg$quit_msg); return(invisible(NULL)) }
      idx <- suppressWarnings(as.integer(c))
      if (!is.na(idx) && idx >=1 && idx <= length(all_dirs)) {
        input_folder <- all_dirs[idx]
        input_path <- file.path(current_dir, input_folder)
        if (grepl("temp|cache|rproj|config", tolower(input_folder))) {
          confirm <- tolower(readline(msg$warn_sys))
          if (confirm != "y") next
        }
        cat(sprintf(msg$selected_input, input_folder), "\n")
        break
      }
      cat(msg$invalid_num, "\n")
    }
    
    # ------------------------------
    # 步骤3：多选图片
    # ------------------------------
    cat("\n", msg$step3, "\n")
    exts <- paste(all_formats, collapse = "|")
    images <- list.files(input_path, pattern = paste0("\\.(", exts, ")$"), ignore.case = TRUE)
    if (length(images) == 0) stop(msg$no_images)
    for (i in seq_along(images)) cat(sprintf("  [%d] %s\n", i, images[i]))
    
    selected_images <- NULL
    repeat {
      c <- trimws(readline(msg$img_prompt))
      if (tolower(c) %in% c("quit", "q")) { message(msg$quit_msg); return(invisible(NULL)) }
      ids <- suppressWarnings(as.integer(strsplit(c, "\\s+")[[1]]))
      ids <- ids[!is.na(ids)]
      if (length(ids) > 0 && all(ids >=1 & ids <= length(images))) {
        selected_images <- images[ids]
        cat(sprintf(msg$selected_img, length(selected_images)), "\n")
        break
      }
      cat(msg$invalid_num, "\n")
    }
    
    # ------------------------------
    # 步骤4：输出文件夹（new 新建）
    # ------------------------------
    cat("\n", msg$step4, "\n")
    for (i in seq_along(all_dirs)) cat(sprintf("  [%d] %s\n", i, all_dirs[i]))
    output_folder <- NULL
    output_path <- NULL
    repeat {
      c <- tolower(trimws(readline(msg$output_prompt)))
      if (c %in% c("quit", "q")) { message(msg$quit_msg); return(invisible(NULL)) }
      if (c == "new") {
        n <- trimws(readline(msg$new_folder_name))
        p <- file.path(current_dir, n)
        if (dir.exists(p)) { cat(msg$folder_exists, "\n"); next }
        dir.create(p)
        output_folder <- n
        output_path <- p
        cat(sprintf(msg$folder_created, n), "\n")
        break
      }
      idx <- suppressWarnings(as.integer(c))
      if (!is.na(idx) && idx >=1 && idx <= length(all_dirs)) {
        output_folder <- all_dirs[idx]
        output_path <- file.path(current_dir, output_folder)
        break
      }
      cat(msg$invalid_num, "\n")
    }
    cat(sprintf(msg$selected_output, output_folder), "\n")
    
    # ------------------------------
    # 步骤5：多选导出格式
    # ------------------------------
    cat("\n", msg$step5, "\n")
    cat(msg$fmt_list, paste(all_formats, collapse = " | "), "\n")
    selected_formats <- NULL
    repeat {
      c <- trimws(readline(msg$fmt_prompt))
      if (tolower(c) %in% c("quit", "q")) { message(msg$quit_msg); return(invisible(NULL)) }
      fs <- tolower(strsplit(c, "\\s+")[[1]])
      fs <- fs[fs != ""]
      if (all(fs %in% all_formats)) {
        selected_formats <- unique(fs)
        cat(sprintf(msg$selected_fmt, paste(selected_formats, collapse = ", ")), "\n")
        break
      }
      cat(msg$invalid_fmt, "\n")
    }
    
    # JPG 质量
    jpg_q <- 95
    if (any(selected_formats %in% c("jpg", "jpeg"))) {
      q <- trimws(readline(msg$jpg_quality))
      qv <- suppressWarnings(as.integer(q))
      if (!is.na(qv) && qv >=1 && qv <=100) jpg_q <- qv
    }
    
    # ------------------------------
    # 批量转换（一张图 → N 种格式）
    # ------------------------------
    cat(msg$converting, "\n")
    total_suc <- 0
    total_fail <- 0
    
    for (img_file in selected_images) {
      in_path <- file.path(input_path, img_file)
      base <- tools::file_path_sans_ext(img_file)
      
      for (fmt in selected_formats) {
        out_path <- file.path(output_path, paste0(base, ".", fmt))
        cnt <- 1
        while (file.exists(out_path)) {
          out_path <- file.path(output_path, paste0(base, "_", cnt, ".", fmt))
          cnt <- cnt + 1
        }
        
        tryCatch({
          img <- image_read(in_path)
          if (fmt %in% c("jpg", "jpeg")) {
            image_write(img, path = out_path, format = fmt, quality = jpg_q)
          } else {
            image_write(img, path = out_path, format = fmt)
          }
          cat(sprintf(msg$success, img_file, basename(out_path)), "\n")
          total_suc <- total_suc + 1
        }, error = function(e) {
          cat(sprintf(msg$fail, img_file, conditionMessage(e)), "\n")
          total_fail <<- total_fail + 1
        })
      }
    }
    
    # 完成统计
    cat(msg$done, "\n")
    cat(sprintf(msg$total_suc, total_suc), "\n")
    cat(sprintf(msg$total_fail, total_fail), "\n")
    cat(msg$repeat_msg, "\n")
  }
}

# 保存并加载
save(TransPicture, file = "TransPicture.Rdata")
load("TransPicture.Rdata")
