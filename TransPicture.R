TransPicture <- function() {
  # ============================================================================
  # 交互式图片格式转换函数
  # 功能：批量/选择性转换图片格式，支持智能识别文件夹命名、自动处理文件冲突
  # 依赖：magick 包
  # ============================================================================
  
  # 检查并安装/加载 magick 包
  if (!require("magick", quietly = TRUE)) {
    message("正在安装 magick 包...")
    install.packages("magick")
    library(magick)
  }
  
  # ----------------------------------------------------------------------------
  # 步骤1：读取工作目录并列出所有文件夹（过滤隐藏/系统文件夹）
  # ----------------------------------------------------------------------------
  
  cat("\n========== 步骤1：工作目录扫描 ==========\n")
  current_dir <- getwd()
  cat("当前工作目录:", current_dir, "\n")
  
  # 获取所有文件夹（不包括子目录），过滤隐藏/系统文件夹
  all_dirs <- list.dirs(path = current_dir, full.names = FALSE, recursive = FALSE)
  all_dirs <- all_dirs[!grepl("^\\.", all_dirs) & all_dirs != ""]
  
  if (length(all_dirs) == 0) {
    stop("当前目录下不存在有效的工作文件夹（已自动排除隐藏文件夹如.Rproj.user等）。\n",
         "请先创建输入/输出文件夹（确保不以点开头）。")
  }
  
  cat("\n已发现的有效文件夹（自动隐藏系统文件夹）：\n")
  for (i in seq_along(all_dirs)) {
    cat(sprintf("  [%d] %s\n", i, all_dirs[i]))
  }
  
  # ----------------------------------------------------------------------------
  # 步骤2：选择输入文件夹（增加二次确认机制）
  # ----------------------------------------------------------------------------
  
  cat("\n========== 步骤2：选择输入端 ==========\n")
  input_folder <- NULL
  repeat {
    input_choice <- readline(prompt = "请输入输入文件夹对应的阿拉伯数字：")
    input_idx <- suppressWarnings(as.integer(input_choice))
    
    if (!is.na(input_idx) && input_idx >= 1 && input_idx <= length(all_dirs)) {
      input_folder <- all_dirs[input_idx]
      input_path <- file.path(current_dir, input_folder)
      
      # 安全检查：可疑文件夹二次确认
      suspicious <- grepl("rproj|temp|cache|config", tolower(input_folder))
      if (suspicious) {
        confirm <- readline(sprintf(
          "警告：'%s' 看起来像是系统/缓存文件夹，确定要作为输入吗？(y/n): ", 
          input_folder
        ))
        if (tolower(confirm) != "y") next
      }
      
      cat(sprintf("已选择输入文件夹: %s\n", input_folder))
      break
    } else {
      cat(sprintf("无效输入，请输入 1 到 %d 之间的数字。\n", length(all_dirs)))
    }
  }
  
  # ----------------------------------------------------------------------------
  # 步骤3：选择图片处理方式
  # ----------------------------------------------------------------------------
  
  cat("\n========== 步骤3：图片选择模式 ==========\n")
  cat("A - 转换文件夹内所有支持的图片\n")
  cat("B - 手动选择特定图片（支持多选）\n")
  
  supported_ext <- c("jpg", "jpeg", "png", "tiff", "tif", "bmp", "gif", "webp", "svg")
  pattern_str <- paste0("\\.(", paste(supported_ext, collapse = "|"), ")$")
  
  # 选择处理模式
  repeat {
    mode_choice <- toupper(readline(prompt = "请输入 A 或 B："))
    if (mode_choice %in% c("A", "B")) break
    cat("无效输入，请输入 A 或 B。\n")
  }
  
  # 获取文件夹内所有支持的图片
  all_images <- list.files(
    path = input_path, 
    pattern = pattern_str, 
    ignore.case = TRUE, 
    full.names = FALSE
  )
  
  if (length(all_images) == 0) {
    stop(sprintf("在 '%s' 中未找到支持的图片格式。", input_folder))
  }
  
  # 选择要转换的图片
  selected_images <- if (mode_choice == "A") {
    cat(sprintf("\n已选择全部 %d 张图片。\n", length(all_images)))
    all_images
  } else {
    cat("\n可用图片列表：\n")
    for (i in seq_along(all_images)) {
      cat(sprintf("  [%d] %s\n", i, all_images[i]))
    }
    
    repeat {
      img_input <- readline(prompt = "\n请输入要转换的图片编号（空格分隔）：")
      img_indices <- suppressWarnings(as.integer(strsplit(trimws(img_input), "\\s+")[[1]]))
      img_indices <- img_indices[!is.na(img_indices)]
      
      if (length(img_indices) > 0 && all(img_indices >= 1 & img_indices <= length(all_images))) {
        cat(sprintf("已选择 %d 张图片。\n", length(img_indices)))
        break
      }
      cat("输入包含无效编号。\n")
    }
    all_images[img_indices]
  }
  
  # ----------------------------------------------------------------------------
  # 步骤4：选择输出文件夹
  # ----------------------------------------------------------------------------
  
  cat("\n========== 步骤4：选择输出端 ==========\n")
  for (i in seq_along(all_dirs)) {
    marker <- if (all_dirs[i] == input_folder) " [当前输入]" else ""
    cat(sprintf("  [%d] %s%s\n", i, all_dirs[i], marker))
  }
  
  repeat {
    output_choice <- readline(prompt = "请输入输出文件夹对应的阿拉伯数字：")
    output_idx <- suppressWarnings(as.integer(output_choice))
    
    if (!is.na(output_idx) && output_idx >= 1 && output_idx <= length(all_dirs)) {
      output_folder <- all_dirs[output_idx]
      output_path <- file.path(current_dir, output_folder)
      cat(sprintf("已选择输出文件夹: %s\n", output_folder))
      break
    }
    cat(sprintf("无效输入，请输入 1 到 %d 之间的数字。\n", length(all_dirs)))
  }
  
  # ----------------------------------------------------------------------------
  # 步骤5：智能格式识别与执行转换
  # ----------------------------------------------------------------------------
  
  cat("\n========== 步骤5：智能格式转换 ==========\n")
  
  # 定义格式识别函数
  detect_format <- function(folder_name) {
    clean_name <- tolower(trimws(folder_name))
    format_map <- list(
      jpeg = c("jpeg", "jpg"), jpg = c("jpg", "jpeg"),
      png = c("png"), tiff = c("tiff", "tif"), tif = c("tif", "tiff"),
      bmp = c("bmp"), gif = c("gif"), webp = c("webp"), svg = c("svg")
    )
    
    for (fmt in names(format_map)) {
      if (clean_name %in% format_map[[fmt]]) return(fmt)
    }
    return(NA)
  }
  
  # 识别输入输出格式
  input_format <- detect_format(input_folder)
  output_format <- detect_format(output_folder)
  
  cat(sprintf("输入识别格式: %s\n", ifelse(is.na(input_format), "未识别", input_format)))
  cat(sprintf("输出识别格式: %s\n", ifelse(is.na(output_format), "未识别（默认png）", output_format)))
  
  if (is.na(output_format)) {
    output_format <- "png"
    cat("使用默认输出格式: png\n")
  }
  
  # 执行转换
  cat(sprintf("\n开始转换 %d 张图片...\n", length(selected_images)))
  success_count <- 0
  fail_count <- 0
  
  for (img_name in selected_images) {
    input_file <- file.path(input_path, img_name)
    base_name <- tools::file_path_sans_ext(img_name)
    output_file <- file.path(output_path, paste0(base_name, ".", output_format))
    
    # 处理文件名冲突
    counter <- 1
    orig_output <- output_file
    while (file.exists(output_file) && output_file != input_file) {
      output_file <- file.path(output_path, paste0(base_name, "_", counter, ".", output_format))
      counter <- counter + 1
    }
    
    tryCatch({
      # 读取并写入图片
      img <- image_read(input_file)
      if (output_format %in% c("jpeg", "jpg")) {
        image_write(img, path = output_file, format = output_format, quality = 95)
      } else {
        image_write(img, path = output_file, format = output_format)
      }
      
      cat(sprintf("  ✓ %s -> %s\n", img_name, basename(output_file)))
      success_count <- success_count + 1
      
    }, error = function(e) {
      cat(sprintf("  ✗ %s 失败: %s\n", img_name, conditionMessage(e)))
      fail_count <- fail_count + 1
    })
  }
  
  # 输出转换结果
  cat(sprintf("\n========== 转换完成 ==========\n"))
  cat(sprintf("成功转换: %d 张\n", success_count))
  cat(sprintf("转换失败: %d 张\n", fail_count))
  cat(sprintf("总处理数量: %d 张\n", length(selected_images)))
  
  # 返回转换结果（可选）
  return(list(
    success = success_count,
    failed = fail_count,
    total = length(selected_images),
    input_folder = input_folder,
    output_folder = output_folder,
    output_format = output_format
  ))
}
save(TransPicture,file = "TransPicture.Rdata")
load(file = "TransPicture.Rdata")
#用的时候直接加载"TransPicture.Rdata"就行了。