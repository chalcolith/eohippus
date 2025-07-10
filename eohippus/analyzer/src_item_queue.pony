use "collections"

class SrcItemQueue
  let _analyzer: EohippusAnalyzer

  let src_items: Map[String, SrcItem] = src_items.create()
  let _src_item_queue: Array[SrcItem] = _src_item_queue.create()

  new create(analyzer: EohippusAnalyzer) =>
    _analyzer = analyzer

  fun queue_size(): USize =>
    _src_item_queue.size()

  fun ref clear() =>
    src_items.clear()
    src_items.compact()
    _src_item_queue.clear()
    _src_item_queue.compact()

  fun ref enqueue_src_item(
    src_item: SrcItem,
    new_state: (SrcItemState | None) = None,
    auto_transition: Bool = false)
  =>
    let canonical_path = src_item.get_canonical_path()
    src_items.update(canonical_path.path, src_item)
    match new_state
    | let new_state': SrcItemState =>
      src_item.set_state(new_state')
    else
      if auto_transition then
        let new_state' =
          match src_item.get_state()
          | AnalysisStart => AnalysisParse
          | AnalysisParse => AnalysisScope
          | AnalysisScope => AnalysisLint
          | AnalysisLint => AnalysisUpToDate
          | AnalysisUpToDate => AnalysisUpToDate
          | AnalysisError => AnalysisError
          end
        src_item.set_state(new_state')
      end
    end

    _src_item_queue.push(src_item)
    _analyzer._process_src_item_queue()

  fun ref shift(): (SrcItem | None) =>
    try
      _src_item_queue.shift()?
    end
